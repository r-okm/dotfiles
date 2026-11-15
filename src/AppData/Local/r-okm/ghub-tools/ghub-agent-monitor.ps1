<#
.SYNOPSIS
    lghub_agent.exe の疎通と、アプリ別プロファイルの切り替わりを記録する。

.DESCRIPTION
    agent は応答しなくなることがあり、スリープ復帰後に多い。それとは別に、agent が応答していて
    自動切替もオンなのに、ゲームを起動してもデスクトップのプロファイルのままになることがある
    （2026-11-14 に発生。G HUB の UI を起動したら切り替わった）。どちらについても、いつ起きて
    どれだけ続いたかを、ghub-resume-recovery.log と突き合わせて調べられるように残す。

    記録するのは、agent の疎通の変化、ゲームと G HUB の UI の起動・終了、有効なプロファイルの変化、
    自動切替の設定の変化、ゲームが前面にあるのにプロファイルが一致しないこと。
    ghub-resume-recovery.log も agent の PID を記録しているので、プロファイルに関わる記録には
    agent の PID と起動時刻を添える。

    計測専用で、agent には何もしない。復旧を行うほかのスクリプトと同時に動かしてよい。
    復旧すると調べたい状態が消えるため、不一致を見つけても再起動しない。

.NOTES
    ログ: このスクリプトと同じディレクトリの ghub-agent-monitor.log
    タスクの登録・解除の手順は、同じディレクトリの README.md にある。
#>

param(
    [int]$IntervalSeconds = 30,
    # ゲームの実行中は、前面に来てから切り替わるまでの数秒を見分けるため、間隔を詰める
    [int]$GameIntervalSeconds = 2,
    # ゲームが前面にあるまま、この秒数プロファイルが一致しなければ不一致として記録する。
    # 正常時は前面に来てから2秒以内に切り替わる（実測）
    [int]$SettleSeconds = 5,
    # 監視するゲームのプロセス名（拡張子なし）。
    # G HUB に登録されたアプリの applicationPath のファイル名と一致している必要がある
    [string[]]$GameProcesses = @('GenshinImpact'),
    # 正常が続く間は記録しないため、記録が無いのが「正常」か「止まっている」かを見分ける印を残す
    [int]$HeartbeatMinutes = 60
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# タスクは -File で起動するため、-GameProcesses A,B は配列ではなく1つの文字列で届く
$GameProcesses = @($GameProcesses -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })

$AgentUri = 'ws://127.0.0.1:9010'
$TimeoutMs = 5000
$ReceiveBufferBytes = 64KB
$UiProcess = 'lghub'
# ghub-resume-recovery.ps1 のタスクのトリガーと同じ復帰イベント
$ResumeEventProvider = 'Microsoft-Windows-Power-Troubleshooter'
$ResumeEventId = 1
$LogPath = Join-Path $PSScriptRoot 'ghub-agent-monitor.log'

# 前回の確認からこの秒数以上空いたら、スリープなどで止まっていたとみなす
$GapSeconds = $IntervalSeconds * 3

Add-Type -Namespace GhubMonitor -Name User32 -MemberDefinition @'
[DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
[DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);
'@

function Write-Log {
    param([string]$Message)
    $line = '{0}  {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    Add-Content -Path $LogPath -Value $line -Encoding UTF8
}

# agent に GET を1回送る。Result は次のどれかで、ok のときだけ Payload が入る。
# refused: 接続を拒否された（agent 不在・起動途中・待ち受け停止）/ timeout(...): 時間内に応答が無い /
# closed / ok / error:<code> / exception:<message>
function Invoke-AgentGet {
    param([string]$Path)

    $ws = [System.Net.WebSockets.ClientWebSocket]::new()
    try {
        $ws.Options.AddSubProtocol('json')
        $ws.Options.SetRequestHeader('Origin', 'file://')
        $deadline = (Get-Date).AddMilliseconds($TimeoutMs)
        $none = [Threading.CancellationToken]::None

        try {
            if (-not $ws.ConnectAsync([Uri]$AgentUri, $none).Wait($TimeoutMs)) { return @{ Result = 'timeout(connect)' } }
        }
        catch { return @{ Result = 'refused' } }

        $request = [Text.Encoding]::UTF8.GetBytes((@{ msgId = ''; verb = 'GET'; path = $Path } | ConvertTo-Json -Compress))
        if (-not $ws.SendAsync([ArraySegment[byte]]::new($request), 'Text', $true, $none).Wait($TimeoutMs)) { return @{ Result = 'timeout(send)' } }

        $buf = [byte[]]::new($ReceiveBufferBytes)
        $stream = [IO.MemoryStream]::new()
        while ($true) {
            $remaining = [int]($deadline - (Get-Date)).TotalMilliseconds
            if ($remaining -le 0) { return @{ Result = 'timeout(receive)' } }

            # ReceiveAsync をキャンセルすると ClientWebSocket ごと中断されるため、タイムアウトは Wait で取る
            $receive = $ws.ReceiveAsync([ArraySegment[byte]]::new($buf), $none)
            if (-not $receive.Wait($remaining)) { return @{ Result = 'timeout(receive)' } }
            if ($receive.Result.MessageType -eq 'Close') { return @{ Result = 'closed' } }

            $stream.Write($buf, 0, $receive.Result.Count)
            if (-not $receive.Result.EndOfMessage) { continue }

            $message = [Text.Encoding]::UTF8.GetString($stream.ToArray()) | ConvertFrom-Json
            $stream.SetLength(0)

            # 接続直後に届く OPTIONS や、ほかの通知を読み飛ばす
            if ($message.verb -ne 'GET' -or $message.path -ne $Path) { continue }
            if ($message.result.code -ne 'SUCCESS') { return @{ Result = "error:$($message.result.code)" } }
            return @{ Result = 'ok'; Payload = $message.payload }
        }
    }
    catch {
        return @{ Result = "exception:$($_.Exception.GetBaseException().Message)" }
    }
    finally {
        $ws.Dispose()
    }
}

function Get-ProcessIds {
    param([string]$Name)
    # Get-Process -Name は該当なしでエラーになるため。agent やゲームの不在は正常な結果
    @([System.Diagnostics.Process]::GetProcessesByName($Name) | ForEach-Object { $_.Id })
}

# 間隔が空いた記録に添える復帰の時刻。ログに添えるだけなので、取れなくても例外にしない
function Get-ResumeNote {
    param([datetime]$Since)

    try {
        $resume = Get-WinEvent -FilterHashtable @{
            LogName = 'System'; ProviderName = $ResumeEventProvider; Id = $ResumeEventId
        } -MaxEvents 1
    }
    catch {
        # 該当なしもエラーになり、例外の型では区別できない
        if ($_.FullyQualifiedErrorId -like 'NoMatchingEventsFound,*') { return '、復帰イベントなし' }
        return "、復帰イベントは不明（$($_.Exception.Message)）"
    }
    if ($resume.TimeCreated -gt $Since) { "、復帰 $($resume.TimeCreated.ToString('HH:mm:ss'))" } else { '、復帰イベントなし' }
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

    $process = Get-CimInstance Win32_Process -Filter "ProcessId=$ProcessId"
    if (-not $process) { return "PID $ProcessId（既に終了）" }
    $parent = Get-CimInstance Win32_Process -Filter "ProcessId=$($process.ParentProcessId)"
    $parentName = if ($parent) { $parent.Name } else { '終了済み' }
    'PID {0}（親: {1} {2}、起動 {3}）' -f $ProcessId, $parentName, $process.ParentProcessId, $process.CreationDate.ToString('HH:mm:ss')
}

# ghub-resume-recovery.log と突き合わせるための agent の PID と起動時刻
function Get-AgentLabel {
    param([int[]]$AgentIds)

    if ($AgentIds.Count -eq 0) { return 'agent=なし' }
    $parts = foreach ($id in $AgentIds) {
        $process = Get-CimInstance Win32_Process -Filter "ProcessId=$id"
        if ($process) { '{0}（起動 {1}）' -f $id, $process.CreationDate.ToString('MM-dd HH:mm:ss') }
        else { "$id（終了済み）" }
    }
    'agent=' + ($parts -join ',')
}

function Get-ForegroundProcessName {
    $processId = [uint32]0
    [void][GhubMonitor.User32]::GetWindowThreadProcessId([GhubMonitor.User32]::GetForegroundWindow(), [ref]$processId)
    try {
        [System.Diagnostics.Process]::GetProcessById([int]$processId).ProcessName
    }
    catch [System.ArgumentException] {
        # 調べる間に前面のプロセスが終了した
        $null
    }
}

# プロファイル ID を名前とアプリに引くための一覧。知らない ID が出たときと、ゲームの起動時に取り直す
$profiles = @{}
$applications = @{}

# 取り直せたかを返す。取り直せなかったときは前の一覧を残し、呼び出し元が次の応答で取り直す
function Update-Catalog {
    $profileResponse = Invoke-AgentGet '/profiles'
    $applicationResponse = Invoke-AgentGet '/applications'
    if ($profileResponse.Result -ne 'ok' -or $applicationResponse.Result -ne 'ok') { return $false }

    $script:profiles = @{}
    foreach ($entry in $profileResponse.Payload.profiles) { $script:profiles[$entry.id] = $entry }
    $script:applications = @{}
    foreach ($entry in $applicationResponse.Payload.applications) { $script:applications[$entry.applicationId] = $entry }
    $true
}

function Format-Profile {
    param([string]$ProfileId)

    if (-not $profiles.ContainsKey($ProfileId)) { return "ID $ProfileId（一覧に無い）" }
    $entry = $profiles[$ProfileId]
    $appName = if ($applications.ContainsKey($entry.applicationId)) { $applications[$entry.applicationId].name } else { '（一覧に無いアプリ）' }
    "$appName / $($entry.name)"
}

# 1つのゲームに複数のアプリ登録がありうるので、配列で返す
function Get-GameApplicationIds {
    param([string]$ProcessName)

    @($applications.Values | Where-Object {
        # デスクトップなど、実行ファイルを持たないアプリには applicationPath が無い
        $path = $_.PSObject.Properties['applicationPath']
        $path -and [IO.Path]::GetFileNameWithoutExtension($path.Value) -ieq $ProcessName
    } | ForEach-Object { $_.applicationId })
}

function Test-GameProfile {
    param([string]$ProfileId, [string]$ProcessName)

    if (-not $profiles.ContainsKey($ProfileId)) { return $false }
    $profiles[$ProfileId].applicationId -in (Get-GameApplicationIds $ProcessName)
}

# protobuf の JSON 表現は既定値を省くため、false のときは value そのものが無い
function Format-AutoSwitching {
    param([hashtable]$Response)

    if ($Response.Result -ne 'ok') { return "取得できず（$($Response.Result)）" }
    $value = $Response.Payload.PSObject.Properties['value']
    if ($value -and $value.Value) { 'オン' } else { 'オフ' }
}

Write-Log ('監視を開始します（間隔 {0}秒、ゲームの実行中は {1}秒。ゲーム: {2}）' -f $IntervalSeconds, $GameIntervalSeconds, ($GameProcesses -join ', '))

# Stop-ScheduledTask はタスクが起動した conhost.exe だけを終了させ、このプロセスは残る。
# 状態は Ready に戻るので、そのまま起動し直すと二重に動く。親がいなくなったら自分で終わる
$parentId = (Get-CimInstance Win32_Process -Filter "ProcessId=$PID").ParentProcessId
$parent = [System.Diagnostics.Process]::GetProcessById($parentId)

$lastSample = $null
$lastState = $null
$lastLogged = Get-Date
$lastUnresponsiveLogged = $null
$knownAgentIds = @()
# プロセス名ごとの「動いているか」。起動直後の1回目は、変化ではなく現状として記録する
$runningProcesses = @{}
# ゲームのプロセスの起動時刻。起動直後は agent がプロセスを見つけるまでの時間がかかるので、不一致の記録に起動からの秒数を添える
$gameStartTimes = @{}
$gameRunning = $false
$lastActiveId = $null
# 一覧を取り直す必要があるか。ゲームの起動時に立て、取り直せるまで（agent が応答しない間も）残す
$catalogStale = $true
# 一覧を取り直しても見つからなかった ID。同じ ID で毎回取り直さないために持つ
$lastCatalogMissId = $null
$lastAutoSwitching = $null
$autoSwitchingCheckedAt = $null
# ゲームが前面にある間の状態。前面から外れたら捨てる。Alt+Tab 中はデスクトップのプロファイルになるのが正常なため
$episode = $null
# 最後に記録した不一致（Game, At）。一致に戻るまでの時間を添えるために持つ。
# UI など別のウィンドウが前面にある間に戻ることもあるので、前面の状態とは別に持つ
$mismatch = $null
$lastError = $null
$lastErrorLogged = $null

while ($true) {
    if ($parent.HasExited) {
        Write-Log "親プロセス (PID $parentId) が終了したため、監視を終了します"
        exit 0
    }

    # 常駐が目的なので、一過性のエラー（ログの一時ロックなど）でループを抜けない。
    # 抜けると無言で記録が止まり、次のログオンまで復旧しない。
    try {
        $sampleAt = Get-Date

        if ($lastSample -and ($sampleAt - $lastSample).TotalSeconds -ge $GapSeconds) {
            Write-Log ('間隔が空きました: 前回 {0} から {1}秒{2}' -f $lastSample.ToString('HH:mm:ss'), [int]($sampleAt - $lastSample).TotalSeconds, (Get-ResumeNote $lastSample))
            $lastLogged = $sampleAt
        }

        $agentIds = @(Get-ProcessIds 'lghub_agent')
        foreach ($id in $agentIds | Where-Object { $_ -notin $knownAgentIds }) {
            Write-Log "新しい agent: $(Get-ProcessOrigin $id)"
            $lastLogged = $sampleAt
        }
        $knownAgentIds = $agentIds

        # UI は Electron で同名のプロセスが複数あるため、PID ではなく「動いているか」の変化を見る
        foreach ($name in @($GameProcesses) + $UiProcess) {
            $ids = @(Get-ProcessIds $name)
            $running = $ids.Count -gt 0
            $known = $runningProcesses.ContainsKey($name)
            $wasRunning = $known -and $runningProcesses[$name]
            if (-not $known) {
                if ($running) { Write-Log "$name は動いています (PID $($ids -join ',')) $(Get-AgentLabel $agentIds)" }
            }
            elseif ($running -and -not $wasRunning) {
                Write-Log "$name が起動しました (PID $($ids -join ',')) $(Get-AgentLabel $agentIds)"
            }
            elseif (-not $running -and $wasRunning) {
                Write-Log "$name が終了しました"
                if ($mismatch -and $mismatch.Game -eq $name) { $mismatch = $null }
            }
            if ($running -and -not $wasRunning -and $name -in $GameProcesses) {
                $catalogStale = $true
                $gameStartTimes[$name] = (Get-CimInstance Win32_Process -Filter "ProcessId=$($ids[0])").CreationDate
            }
            $runningProcesses[$name] = $running
        }
        $gameRunning = @($GameProcesses | Where-Object { $runningProcesses[$_] }).Count -gt 0

        $requestAt = Get-Date
        $active = Invoke-AgentGet '/profile/active'
        $result = $active.Result
        $elapsedMs = [int]((Get-Date) - $requestAt).TotalMilliseconds
        $state = '{0} agent={1}' -f $result, ($agentIds -join ',')

        # 状態が変わったときと、応答が無いときは記録する。正常が続く間は記録しない。
        # 応答が無い間は、ゲームの実行中に間隔を詰めても記録が増えすぎないよう、通常の間隔ごとに記録する
        if ($result -ne 'ok') {
            if ($state -ne $lastState -or -not $lastUnresponsiveLogged -or
                ($sampleAt - $lastUnresponsiveLogged).TotalSeconds -ge $IntervalSeconds) {
                Write-Log ('{0} ({1}ms) {2}' -f $state, $elapsedMs, (Get-ListenSummary $agentIds))
                $lastUnresponsiveLogged = $sampleAt
                $lastLogged = $sampleAt
            }
        }
        elseif ($state -ne $lastState) {
            Write-Log ('{0} ({1}ms)' -f $state, $elapsedMs)
            $lastLogged = $sampleAt
        }
        elseif (($sampleAt - $lastLogged).TotalMinutes -ge $HeartbeatMinutes) {
            Write-Log "動作中: $state"
            $lastLogged = $sampleAt
        }

        $activeId = $null
        if ($result -eq 'ok') {
            $activeId = $active.Payload.id
            if ($catalogStale -or (-not $profiles.ContainsKey($activeId) -and $activeId -ne $lastCatalogMissId)) {
                # 取り直せなかったときは、どちらの状態も変えずに次の応答で取り直す
                if (Update-Catalog) {
                    $catalogStale = $false
                    $lastCatalogMissId = if ($profiles.ContainsKey($activeId)) { $null } else { $activeId }
                }
            }

            # ゲームの実行中に毎回問い合わせると agent への接続が倍になるので、通常の間隔ごとに取る。
            # 不一致の記録には、そのときの値を取り直して添える
            if (-not $autoSwitchingCheckedAt -or ($sampleAt - $autoSwitchingCheckedAt).TotalSeconds -ge $IntervalSeconds) {
                $autoSwitching = Format-AutoSwitching (Invoke-AgentGet '/profiles/auto_switching')
                $autoSwitchingCheckedAt = $sampleAt
                # 取得の失敗は設定の変化ではないので、オン・オフが変わったときだけ記録する
                if ($autoSwitching -in 'オン', 'オフ' -and $autoSwitching -ne $lastAutoSwitching) {
                    Write-Log "自動切替: $autoSwitching"
                    $lastAutoSwitching = $autoSwitching
                    $lastLogged = $sampleAt
                }
            }
        }

        $foreground = Get-ForegroundProcessName
        $game = $GameProcesses | Where-Object { $_ -ieq $foreground } | Select-Object -First 1
        if (-not $game) {
            $episode = $null
        }
        elseif (-not $episode -or $episode.Game -ne $game) {
            # 監視の開始時にすでに前面にあった場合、前面になった時刻は分からない
            $episode = @{ Game = $game; Since = $sampleAt; SinceKnown = [bool]$lastSample; MismatchSince = $null; Reported = $false }
        }

        if ($activeId -and $activeId -ne $lastActiveId) {
            $notes = @("前面: $(if ($foreground) { $foreground } else { '不明' })")
            if ($episode -and $episode.SinceKnown) {
                $notes += '前面になって{0}秒後' -f [int]($sampleAt - $episode.Since).TotalSeconds
            }
            if ($mismatch -and (Test-GameProfile $activeId $mismatch.Game)) {
                $notes += '不一致の記録から{0}秒後' -f [int]($sampleAt - $mismatch.At).TotalSeconds
                $mismatch = $null
            }
            Write-Log ('有効なプロファイル: {0}（{1}） {2}' -f (Format-Profile $activeId), ($notes -join '、'), (Get-AgentLabel $agentIds))
            $lastActiveId = $activeId
            $lastLogged = $sampleAt
        }

        # 一致したあとに前面のままデスクトップへ戻った場合も拾えるよう、一致しない状態が続いた時間で判定する
        if ($episode) {
            if ($activeId -and (Test-GameProfile $activeId $episode.Game)) {
                # 有効なプロファイルが変わらずに一致へ戻った場合（agent が応答しなかった間の不一致など）は、上の記録に出ない
                if ($mismatch -and $mismatch.Game -eq $episode.Game) {
                    Write-Log ('一致しました: 有効なプロファイル = {0}（不一致の記録から{1}秒後） {2}' -f
                        (Format-Profile $activeId), [int]($sampleAt - $mismatch.At).TotalSeconds, (Get-AgentLabel $agentIds))
                    $mismatch = $null
                    $lastLogged = $sampleAt
                }
                $episode.MismatchSince = $null
                $episode.Reported = $false
            }
            elseif (-not $episode.MismatchSince) {
                $episode.MismatchSince = $sampleAt
            }
            elseif (-not $episode.Reported -and ($sampleAt - $episode.MismatchSince).TotalSeconds -ge $SettleSeconds) {
                $duration = '前面のまま{0}秒' -f [int]($sampleAt - $episode.MismatchSince).TotalSeconds
                if (-not $episode.SinceKnown -and $episode.MismatchSince -eq $episode.Since) { $duration = "監視の開始時から$duration" }
                $startedAt = $gameStartTimes[$episode.Game]
                $sinceStart = if ($startedAt) { '、起動から{0}秒' -f [int]($sampleAt - $startedAt).TotalSeconds } else { '' }
                $activeText = if ($activeId) { Format-Profile $activeId } else { "取得できず（$result）" }
                $autoText = if ($result -eq 'ok') { Format-AutoSwitching (Invoke-AgentGet '/profiles/auto_switching') } else { "取得できず（$result）" }
                # 関数から返した空配列は $null に展開されるため、@() で配列に戻す
                $registration = if (@(Get-GameApplicationIds $episode.Game).Count -eq 0) { "、G HUB に $($episode.Game) のアプリ登録が見つからない" } else { '' }
                Write-Log ('不一致: {0} が{1}{2}、有効なプロファイル = {3}、自動切替 = {4}{5} {6}' -f
                    $episode.Game, $duration, $sinceStart, $activeText, $autoText, $registration, (Get-AgentLabel $agentIds))
                $episode.Reported = $true
                $mismatch = @{ Game = $episode.Game; At = $sampleAt }
                $lastLogged = $sampleAt
            }
        }

        $lastState = $state
        $lastSample = $sampleAt
    }
    catch {
        # ゲームの実行中に同じエラーが続いても記録が増えすぎないよう、同じ内容は通常の間隔ごとに記録する
        $message = $_.Exception.Message
        if ($message -ne $lastError -or ((Get-Date) - $lastErrorLogged).TotalSeconds -ge $IntervalSeconds) {
            Write-Log "ERROR: $message"
            $lastError = $message
            $lastErrorLogged = Get-Date
        }
    }

    $interval = if ($gameRunning) { $GameIntervalSeconds } else { $IntervalSeconds }
    $wait = $interval - ((Get-Date) - $sampleAt).TotalSeconds
    if ($wait -gt 0) { Start-Sleep -Milliseconds ([int]($wait * 1000)) }
}
