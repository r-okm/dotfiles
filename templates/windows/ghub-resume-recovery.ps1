<#
.SYNOPSIS
    スリープ復帰後に lghub_agent.exe が応答しなければ、再起動して復旧する。

.DESCRIPTION
    スリープ復帰後、agent はプロセスが生きたまま WebSocket (ws://127.0.0.1:9010) の
    接続を拒否するようになることがある。自然には直らず（2時間近く続いた実測あり）、その間は
    UI がスプラッシュ画面で止まり、アプリ別プロファイルも切り替わらない。
    ghub-agent-monitor.ps1 の記録では、固まる回は復帰直後の最初の確認から応答していなかった。

    復帰から一定時間疎通を確かめ、一度も応答しなければ agent を強制終了する。
    lghub_system_tray.exe が新しい agent を起動し直し、それで復旧する。

.NOTES
    ログ: %LOCALAPPDATA%\ghub-resume-recovery.log

    スリープ・休止状態からの復帰（System ログ、Microsoft-Windows-Power-Troubleshooter、
    イベント ID 1）をトリガーとするタスクとして登録する。tray はスタートアップから
    管理者権限なしで動いており、その子の agent も管理者権限なしで終了できるため、
    タスクも管理者権限なしで動かす。$script は実際の配置先の絶対パスに置き換える。

        $script = 'C:\Scripts\ghub-resume-recovery.ps1'
        $user   = "$env:USERDOMAIN\$env:USERNAME"

        $trigger = Get-CimClass -Namespace Root/Microsoft/Windows/TaskScheduler -ClassName MSFT_TaskEventTrigger |
            New-CimInstance -ClientOnly
        $trigger.Enabled      = $true
        $trigger.Subscription = @'
<QueryList><Query Id="0" Path="System"><Select Path="System">*[System[Provider[@Name='Microsoft-Windows-Power-Troubleshooter'] and EventID=1]]</Select></Query></QueryList>
'@
        $action    = New-ScheduledTaskAction -Execute 'conhost.exe' `
                         -Argument "--headless powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$script`""
        $principal = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Limited
        $settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
                         -ExecutionTimeLimit (New-TimeSpan -Minutes 5) -MultipleInstances IgnoreNew

        Register-ScheduledTask -TaskName 'GhubResumeRecovery' -Action $action -Trigger $trigger `
                               -Principal $principal -Settings $settings

    conhost.exe --headless を挟むのは、既定のターミナルが Windows Terminal だと
    コンソールがそちらに委任され、powershell.exe -WindowStyle Hidden ではウィンドウが残るため。
#>

param(
    # この秒数の間に一度も応答しなければ固まっているとみなす。
    # 正常な回に復帰直後だけ一時的に応答しないことがあるかは未計測なので、その分の猶予を取る
    [int]$CheckWindowSeconds = 30,
    [int]$IntervalSeconds = 5,
    # agent を強制終了してから、新しい agent が応答するまで待つ秒数。
    # lghub_system_tray.exe による起動し直しは2〜20秒（実測）。
    [int]$RestartTimeoutSeconds = 30
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$AgentUri = 'ws://127.0.0.1:9010'
$TimeoutMs = 5000
$LogPath = Join-Path $env:LOCALAPPDATA 'ghub-resume-recovery.log'

function Write-Log {
    param([string]$Message)
    $line = '{0}  {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    Add-Content -Path $LogPath -Value $line -Encoding UTF8
}

# /profile/active を1回問い合わせ、結果の種類を返す。
# refused: 接続を拒否された（agent 不在・起動途中・待ち受け停止）/ timeout(...): 時間内に応答が無い / ok / error:<code>
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

function Get-AgentIds {
    @(Get-Process -Name 'lghub_agent' -ErrorAction SilentlyContinue | ForEach-Object { $_.Id })
}

# 新しい agent が起動して応答するまで待つ。応答した agent の PID を返し、時間切れなら $null
function Wait-AgentReady {
    param([int[]]$ExcludeIds, [int]$TimeoutSeconds)

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        $new = @(Get-AgentIds | Where-Object { $_ -notin $ExcludeIds })
        if ($new.Count -gt 0 -and (Test-Agent) -eq 'ok') { return $new[0] }
        Start-Sleep -Seconds 1
    }
    $null
}

$resume = Get-WinEvent -FilterHashtable @{
    LogName = 'System'; ProviderName = 'Microsoft-Windows-Power-Troubleshooter'; Id = 1
} -MaxEvents 1 -ErrorAction SilentlyContinue
$resumeText = if ($resume) { $resume.TimeCreated.ToString('HH:mm:ss') } else { '不明' }

try {
    $start = Get-Date
    $results = @()
    while ($true) {
        $result = Test-Agent
        $results += $result
        if ($result -eq 'ok') {
            Write-Log ('復帰 {0}: agent は応答しています（{1}回目の確認、{2}）' -f $resumeText, $results.Count, ($results -join ' '))
            exit 0
        }
        if (((Get-Date) - $start).TotalSeconds -ge $CheckWindowSeconds) { break }
        Start-Sleep -Seconds $IntervalSeconds
    }

    $oldIds = @(Get-AgentIds)
    Write-Log ('復帰 {0}: agent が {1}秒間応答しません（{2}）' -f $resumeText, $CheckWindowSeconds, ($results -join ' '))

    if ($oldIds.Count -eq 0) {
        # プロセスが無いなら tray が起動し直す途中の可能性があり、終了させるものが無い
        Write-Log 'lghub_agent が存在しないため、起動を待ちます'
    }
    else {
        Write-Log "lghub_agent を再起動します (PID: $($oldIds -join ','))"
        foreach ($id in $oldIds) {
            # 古い PID が消えたかでは成否を決めず、新しい agent が応答するかで判断する。
            # Wait-Process が終了を確認した直後でも Get-Process には古い PID が見えることがある（実測）。
            # ghub-profile-watcher.ps1 が先に終了させていた場合のエラーもここで無視してよい
            Stop-Process -Id $id -Force -ErrorAction SilentlyContinue
            Wait-Process -Id $id -Timeout 10 -ErrorAction SilentlyContinue
        }
    }

    $newId = Wait-AgentReady -ExcludeIds $oldIds -TimeoutSeconds $RestartTimeoutSeconds
    if ($newId) {
        Write-Log "lghub_agent が起動しました (PID: $newId)"
        exit 0
    }
    Write-Log 'ERROR: lghub_agent が起動しませんでした。G HUB を手動で起動してください'
    exit 1
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    exit 1
}
