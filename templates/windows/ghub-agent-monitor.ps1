<#
.SYNOPSIS
    lghub_agent.exe が WebSocket に応答するかを定期的に確かめ、状態の変化を記録する。

.DESCRIPTION
    agent は応答しなくなることがあり、スリープ復帰後に多い。ただ、復帰直後から
    応答しないのか、しばらくしてからなのか、スリープと関係なく起きるのかが分かっていない。
    それを見分けるため、常駐して疎通を確かめ続け、固まった時刻と続いた時間を残す。

    計測専用で、agent には何もしない。復旧は ghub-profile-watcher.ps1 が行い、同時に動かしてよい。

.NOTES
    ログ: %LOCALAPPDATA%\ghub-agent-monitor.log

    ログオン時タスクとして登録する。agent を終了させないので管理者権限は不要。
    $script は実際の配置先の絶対パスに置き換える。

        $script = 'C:\Scripts\ghub-agent-monitor.ps1'
        $user   = "$env:USERDOMAIN\$env:USERNAME"

        $action    = New-ScheduledTaskAction -Execute 'conhost.exe' `
                         -Argument "--headless powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$script`""
        $trigger   = New-ScheduledTaskTrigger -AtLogOn -User $user
        $principal = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Limited
        $settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
                         -ExecutionTimeLimit 0 -MultipleInstances IgnoreNew

        Register-ScheduledTask -TaskName 'GhubAgentMonitor' -Action $action -Trigger $trigger `
                               -Principal $principal -Settings $settings

    -ExecutionTimeLimit 0 が無いと既定の3日で強制終了され、常駐が死ぬ。
    conhost.exe --headless を挟むのは、既定のターミナルが Windows Terminal だと
    コンソールがそちらに委任され、powershell.exe -WindowStyle Hidden ではウィンドウが残るため。
    管理者権限で動くタスクは委任されないので、この問題は起きない。
#>

param(
    [int]$IntervalSeconds = 30,
    # 正常が続く間は記録しないため、記録が無いのが「正常」か「止まっている」かを見分ける印を残す
    [int]$HeartbeatMinutes = 60
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$AgentUri = 'ws://127.0.0.1:9010'
$TimeoutMs = 5000
$LogPath = Join-Path $env:LOCALAPPDATA 'ghub-agent-monitor.log'

# 前回の確認からこの秒数以上空いたら、スリープなどで止まっていたとみなす
$GapSeconds = $IntervalSeconds * 3

function Write-Log {
    param([string]$Message)
    $line = '{0}  {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    Add-Content -Path $LogPath -Value $line -Encoding UTF8
}

# /profile/active を1回問い合わせ、結果の種類を返す。
# refused: 接続を拒否された（agent 不在・起動途中）/ timeout(...): 時間内に応答が無い / ok / error:<code>
function Test-Agent {
    $ws = [System.Net.WebSockets.ClientWebSocket]::new()
    try {
        $ws.Options.AddSubProtocol('json')
        $ws.Options.SetRequestHeader('Origin', 'file://')
        $deadline = (Get-Date).AddMilliseconds($TimeoutMs)
        $none = [Threading.CancellationToken]::None

        try {
            if (-not $ws.ConnectAsync([Uri]$AgentUri, $none).Wait($TimeoutMs)) { return 'timeout(connect)' }
        }
        catch { return 'refused' }

        $request = [Text.Encoding]::UTF8.GetBytes('{"msgId":"","verb":"GET","path":"/profile/active"}')
        if (-not $ws.SendAsync([ArraySegment[byte]]::new($request), 'Text', $true, $none).Wait($TimeoutMs)) { return 'timeout(send)' }

        $buf = [byte[]]::new(64KB)
        $stream = [IO.MemoryStream]::new()
        while ($true) {
            $remaining = [int]($deadline - (Get-Date)).TotalMilliseconds
            if ($remaining -le 0) { return 'timeout(receive)' }

            # ReceiveAsync をキャンセルすると ClientWebSocket ごと中断されるため、タイムアウトは Wait で取る
            $receive = $ws.ReceiveAsync([ArraySegment[byte]]::new($buf), $none)
            if (-not $receive.Wait($remaining)) { return 'timeout(receive)' }
            if ($receive.Result.MessageType -eq 'Close') { return 'closed' }

            $stream.Write($buf, 0, $receive.Result.Count)
            if (-not $receive.Result.EndOfMessage) { continue }

            $message = [Text.Encoding]::UTF8.GetString($stream.ToArray()) | ConvertFrom-Json
            $stream.SetLength(0)

            # 接続直後に届く OPTIONS などを読み飛ばす
            if ($message.verb -ne 'GET' -or $message.path -ne '/profile/active') { continue }
            if ($message.result.code -eq 'SUCCESS') { return 'ok' }
            return "error:$($message.result.code)"
        }
    }
    catch {
        return "exception:$($_.Exception.GetBaseException().Message)"
    }
    finally {
        $ws.Dispose()
    }
}

function Get-LastResumeTime {
    $resume = Get-WinEvent -FilterHashtable @{
        LogName = 'System'; ProviderName = 'Microsoft-Windows-Power-Troubleshooter'; Id = 1
    } -MaxEvents 1 -ErrorAction SilentlyContinue
    if ($resume) { $resume.TimeCreated } else { $null }
}

# 応答しないとき、agent が待ち受けを閉じたのか、別のアドレス・ポートに移ったのか、
# 待ち受けたまま接続を受け付けないのかを見分けるため、待ち受けの状況をまとめる
function Get-ListenSummary {
    param([int[]]$AgentIds)

    # if の結果を代入すると、要素1個の配列は単体に、空配列は $null に展開されて .Count が使えなくなるため、
    # 空配列で初期化してから中で代入する
    # -OwningProcess に型付き配列 ([int[]]) を渡すと CIM の型不一致で失敗するため、取得後に絞る
    $listen = @(Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue)
    $agentListen = @()
    if ($AgentIds.Count -gt 0) {
        $agentListen = @($listen | Where-Object { $_.OwningProcess -in $AgentIds } |
            ForEach-Object { '{0}:{1}' -f $_.LocalAddress, $_.LocalPort } | Sort-Object -Unique)
    }
    $port = @($listen | Where-Object { $_.LocalPort -eq 9010 } |
        ForEach-Object { '{0}:{1}(PID {2})' -f $_.LocalAddress, $_.LocalPort, $_.OwningProcess })

    'listen={0} 9010={1}' -f $(if ($agentListen.Count) { $agentListen -join ',' } else { 'なし' }),
        $(if ($port.Count) { $port -join ',' } else { 'なし' })
}

# 誰が agent を起動したか（tray / UI / 復旧スクリプト）と、固まっている間に一瞬だけ
# 現れる2つ目の agent の正体を残すため、新しい PID の親と起動時刻をまとめる
function Get-ProcessOrigin {
    param([int]$ProcessId)

    $process = Get-CimInstance Win32_Process -Filter "ProcessId=$ProcessId" -ErrorAction SilentlyContinue
    if (-not $process) { return "PID $ProcessId（既に終了）" }
    $parent = Get-CimInstance Win32_Process -Filter "ProcessId=$($process.ParentProcessId)" -ErrorAction SilentlyContinue
    $parentName = if ($parent) { $parent.Name } else { '終了済み' }
    'PID {0}（親: {1} {2}、起動 {3}）' -f $ProcessId, $parentName, $process.ParentProcessId, $process.CreationDate.ToString('HH:mm:ss')
}

Write-Log "監視を開始します（間隔 ${IntervalSeconds}秒）"

# Stop-ScheduledTask はタスクが起動した conhost.exe だけを終了させ、このプロセスは残る。
# 状態は Ready に戻るので、そのまま起動し直すと二重に動く。親がいなくなったら自分で終わる
$parentId = (Get-CimInstance Win32_Process -Filter "ProcessId=$PID").ParentProcessId

$lastSample = $null
$lastState = $null
$lastLogged = Get-Date
$knownAgentIds = @()

while ($true) {
    if (-not (Get-Process -Id $parentId -ErrorAction SilentlyContinue)) {
        Write-Log "親プロセス (PID $parentId) が終了したため、監視を終了します"
        exit 0
    }

    # 常駐が目的なので、一過性のエラー（ログの一時ロックなど）でループを抜けない。
    # 抜けると無言で記録が止まり、次のログオンまで復旧しない。
    try {
        $sampleAt = Get-Date

        if ($lastSample -and ($sampleAt - $lastSample).TotalSeconds -ge $GapSeconds) {
            $resumeTime = Get-LastResumeTime
            $resumeNote = if ($resumeTime -and $resumeTime -gt $lastSample) { "、復帰 $($resumeTime.ToString('HH:mm:ss'))" } else { '、復帰イベントなし' }
            Write-Log ('間隔が空きました: 前回 {0} から {1}秒{2}' -f $lastSample.ToString('HH:mm:ss'), [int]($sampleAt - $lastSample).TotalSeconds, $resumeNote)
            $lastLogged = $sampleAt
        }

        $agentIds = @(Get-Process -Name 'lghub_agent' -ErrorAction SilentlyContinue | ForEach-Object { $_.Id })
        foreach ($id in $agentIds | Where-Object { $_ -notin $knownAgentIds }) {
            Write-Log "新しい agent: $(Get-ProcessOrigin $id)"
            $lastLogged = $sampleAt
        }
        $knownAgentIds = $agentIds

        $result = Test-Agent
        $elapsedMs = [int]((Get-Date) - $sampleAt).TotalMilliseconds
        $state = '{0} agent={1}' -f $result, ($agentIds -join ',')

        # 状態が変わったときと、応答が無いときは毎回記録する。正常が続く間は記録しない
        if ($result -ne 'ok') {
            Write-Log ('{0} ({1}ms) {2}' -f $state, $elapsedMs, (Get-ListenSummary $agentIds))
            $lastLogged = $sampleAt
        }
        elseif ($state -ne $lastState) {
            Write-Log ('{0} ({1}ms)' -f $state, $elapsedMs)
            $lastLogged = $sampleAt
        }
        elseif (($sampleAt - $lastLogged).TotalMinutes -ge $HeartbeatMinutes) {
            Write-Log "動作中: $state"
            $lastLogged = $sampleAt
        }

        $lastState = $state
        $lastSample = $sampleAt
    }
    catch {
        Write-Log "ERROR: $($_.Exception.Message)"
    }

    $wait = $IntervalSeconds - ((Get-Date) - $sampleAt).TotalSeconds
    if ($wait -gt 0) { Start-Sleep -Milliseconds ([int]($wait * 1000)) }
}
