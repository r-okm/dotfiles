<#
.SYNOPSIS
    対象ゲームの起動を検知し、アプリ別プロファイルが適用されていなければ
    lghub_agent.exe を再起動して復旧する。

.DESCRIPTION
    G HUB の lghub_agent.exe は、時間経過やスリープ復帰によってプロセス監視が停止し、
    ゲーム起動時のアプリ別プロファイル切替を取りこぼすことがある。
    agent を強制終了すると lghub_system_tray.exe が約10秒で起動し直し、
    新しい agent は実行中のゲームを認識してプロファイルを切り替える。

    異常の判定には agent の WebSocket (ws://127.0.0.1:9010) を使い、
    ゲームが前面にあるときに「有効なプロファイルが属するアプリ」と
    「ゲームの exe に対応するアプリ」を比べる。プロファイル ID はスクリプトに持たない。
    ID の振り直しや、1アプリに複数プロファイルがある場合にも判定を誤らないため。

    Win32_ProcessStartTrace の購読には管理者権限が必要。
    タスクスケジューラで「最上位の特権で実行する」を有効にして起動すること。

.PARAMETER CheckOnce
    指定した exe 名 (例: GenshinImpact.exe) について、判定と復旧を1回だけ行って終了する。
    常駐させずに動作を確かめるための診断用で、イベント購読をしないため管理者権限は不要。
    ただし agent が管理者権限で動いている場合、再起動には管理者権限が要る。

.NOTES
    ログ: %LOCALAPPDATA%\ghub-profile-watcher.log

    常駐させるには、任意の場所に配置したうえで管理者権限の PowerShell から
    ログオン時タスクとして登録する。$script は実際の配置先の絶対パスに置き換える。

        $script = 'C:\Scripts\ghub-profile-watcher.ps1'
        $user   = "$env:USERDOMAIN\$env:USERNAME"

        $action    = New-ScheduledTaskAction -Execute 'powershell.exe' `
                         -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$script`""
        $trigger   = New-ScheduledTaskTrigger -AtLogOn -User $user
        $trigger.Delay = 'PT1M'
        $principal = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Highest
        $settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
                         -ExecutionTimeLimit 0 -StartWhenAvailable

        Register-ScheduledTask -TaskName 'GhubProfileWatcher' -Action $action -Trigger $trigger `
                               -Principal $principal -Settings $settings

    -RunLevel Highest は Win32_ProcessStartTrace の購読に必須。
    -ExecutionTimeLimit 0 が無いと既定の3日で強制終了され、常駐が死ぬ。
    $trigger.Delay は G HUB 本体の起動を待つための余裕。
#>

param(
    [string]$CheckOnce
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---- 設定 -------------------------------------------------------------

# 監視対象の実行ファイル名。複数指定可。
# G HUB に登録されたアプリの applicationPath のファイル名と一致している必要がある。
$TargetProcesses = @(
    'GenshinImpact.exe'
)

# ゲーム起動を検知してから、プロファイルの一致を判定し始めるまでの待機秒数。
# agent が応答するかの確認は待たずに行う。
# 下の $SettleSeconds の実測値は、agent が認識済みのゲームに Alt+Tab で戻ったときのもの。
# 起動直後は agent が新しいプロセスを見つけるまでの時間が加わり、それを測っていないため、
# ゲームが早く前面に来ても不一致と誤判定しないよう余裕を取る。原神は操作可能になるまでこれより長くかかる。
$DelayBeforeCheck = 25

# ゲームのウィンドウが前面に来るのを待つ上限秒数。
# ロード中に別のウィンドウを見ていることがあるため長めに取る。
$ForegroundTimeoutSeconds = 600

# ゲームが前面にある状態でこの秒数プロファイルが一致しなければ異常とみなす。
# 正常時は前面に来てから2秒以内に切り替わる（実測）。
$SettleSeconds = 5

# agent を強制終了してから、新しい agent が応答するまで待つ秒数。
# lghub_system_tray.exe による起動し直しは約10秒（実測）。
$AgentRestartTimeoutSeconds = 30

# tray が agent を起動し直さなかったときに、tray ごと起動するためのタスク
$FallbackTaskName = 'LaunchGhub'

$AgentUri = 'ws://127.0.0.1:9010'

$LogPath = Join-Path $env:LOCALAPPDATA 'ghub-profile-watcher.log'

# ---- 実装 -------------------------------------------------------------

Add-Type -Namespace GhubWatcher -Name User32 -MemberDefinition @'
[DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
[DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);
'@

function Write-Log {
    param([string]$Message)
    $line = '{0}  {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    Add-Content -Path $LogPath -Value $line -Encoding UTF8
    if ($CheckOnce) { Write-Host $line }
}

# agent に GET を1回送り、payload を返す。応答が無い・失敗したときは $null。
function Invoke-AgentGet {
    param([string]$Path, [int]$TimeoutMs = 5000)

    $ws = [System.Net.WebSockets.ClientWebSocket]::new()
    try {
        $ws.Options.AddSubProtocol('json')
        $ws.Options.SetRequestHeader('Origin', 'file://')
        $deadline = (Get-Date).AddMilliseconds($TimeoutMs)
        $none = [Threading.CancellationToken]::None

        if (-not $ws.ConnectAsync([Uri]$AgentUri, $none).Wait($TimeoutMs)) { return $null }
        if ($ws.State -ne 'Open') { return $null }

        $request = [Text.Encoding]::UTF8.GetBytes((@{ msgId = ''; verb = 'GET'; path = $Path } | ConvertTo-Json -Compress))
        if (-not $ws.SendAsync([ArraySegment[byte]]::new($request), 'Text', $true, $none).Wait($TimeoutMs)) { return $null }

        $buf = [byte[]]::new(64KB)
        $stream = [IO.MemoryStream]::new()
        while ($true) {
            $remaining = [int]($deadline - (Get-Date)).TotalMilliseconds
            if ($remaining -le 0) { return $null }

            # ReceiveAsync をキャンセルすると ClientWebSocket ごと中断されるため、タイムアウトは Wait で取る
            $receive = $ws.ReceiveAsync([ArraySegment[byte]]::new($buf), $none)
            if (-not $receive.Wait($remaining)) { return $null }
            if ($receive.Result.MessageType -eq 'Close') { return $null }

            $stream.Write($buf, 0, $receive.Result.Count)
            if (-not $receive.Result.EndOfMessage) { continue }

            $message = [Text.Encoding]::UTF8.GetString($stream.ToArray()) | ConvertFrom-Json
            $stream.SetLength(0)

            # 接続直後に届く OPTIONS や、他の通知を読み飛ばす
            if ($message.verb -ne 'GET' -or $message.path -ne $Path) { continue }
            if ($message.result.code -ne 'SUCCESS') { return $null }
            return $message.payload
        }
    }
    catch {
        # 接続拒否（agent 不在・起動途中）もここに来る
        return $null
    }
    finally {
        $ws.Dispose()
    }
}

# 自動切替の設定を返す。応答が無ければ $null。
# protobuf の JSON 表現は既定値を省くため、false のときは value そのものが無い。
function Get-AutoSwitchingEnabled {
    $setting = Invoke-AgentGet '/profiles/auto_switching'
    if ($null -eq $setting) { return $null }
    $value = $setting.PSObject.Properties['value']
    [bool]($value -and $value.Value)
}

# exe 名に対応する G HUB のアプリ ID を返す。
# Responded が $false なら agent が応答していない。Ids が空なら該当するアプリ登録が無い。
function Get-GameApplicationIds {
    param([string]$ExeName)

    $apps = Invoke-AgentGet '/applications'
    if ($null -eq $apps) { return @{ Responded = $false; Ids = @() } }

    $ids = @($apps.applications |
        Where-Object { $_.applicationPath -and [IO.Path]::GetFileName($_.applicationPath) -ieq $ExeName } |
        ForEach-Object { $_.applicationId })
    @{ Responded = $true; Ids = $ids }
}

# 有効なプロファイルが属するアプリの ID を返す。取得できなければ $null。
function Get-ActiveApplicationId {
    $active = Invoke-AgentGet '/profile/active'
    if ($null -eq $active) { return $null }
    $profiles = Invoke-AgentGet '/profiles'
    if ($null -eq $profiles) { return $null }

    $match = @($profiles.profiles | Where-Object { $_.id -eq $active.id })
    if ($match.Count -eq 0) { return $null }
    $match[0].applicationId
}

function Get-ForegroundProcessName {
    $processId = [uint32]0
    [void][GhubWatcher.User32]::GetWindowThreadProcessId([GhubWatcher.User32]::GetForegroundWindow(), [ref]$processId)
    $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
    if ($process) { $process.Name } else { $null }
}

# ゲームが前面にある間にプロファイルが一致するかを見る。
# 前面から外れている時間は数えない。Alt+Tab 中は Desktop プロファイルになるのが正常なため。
# 戻り値: Ok / Mismatch / Exited / Timeout
function Wait-GameProfile {
    param([string]$ExeName, [string[]]$GameApplicationIds, [int]$TimeoutSeconds)

    $processName = [IO.Path]::GetFileNameWithoutExtension($ExeName)
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    $foregroundSince = $null

    while ((Get-Date) -lt $deadline) {
        if (-not (Get-Process -Name $processName -ErrorAction SilentlyContinue)) { return 'Exited' }

        if ((Get-ForegroundProcessName) -ieq $processName) {
            $activeApplicationId = Get-ActiveApplicationId
            if ($activeApplicationId -and $activeApplicationId -in $GameApplicationIds) { return 'Ok' }

            if ($null -eq $foregroundSince) {
                $foregroundSince = Get-Date
            }
            elseif (((Get-Date) - $foregroundSince).TotalSeconds -ge $SettleSeconds) {
                Write-Log "プロファイル不一致: 有効なプロファイルのアプリ = $(if ($activeApplicationId) { $activeApplicationId } else { '(取得できず)' })"
                return 'Mismatch'
            }
        }
        else {
            $foregroundSince = $null
        }
        Start-Sleep -Seconds 1
    }
    'Timeout'
}

function Wait-AgentReady {
    param([int[]]$ExcludeIds, [int]$TimeoutSeconds)

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        $new = @(Get-Process -Name 'lghub_agent' -ErrorAction SilentlyContinue | Where-Object { $_.Id -notin $ExcludeIds })
        if ($new.Count -gt 0 -and $null -ne (Invoke-AgentGet '/profile/active' 2000)) {
            return $new[0].Id
        }
        Start-Sleep -Seconds 1
    }
    $null
}

function Restart-Agent {
    $oldIds = @(Get-Process -Name 'lghub_agent' -ErrorAction SilentlyContinue | ForEach-Object { $_.Id })
    Write-Log "lghub_agent を再起動します (PID: $(if ($oldIds.Count) { $oldIds -join ',' } else { 'なし' }))"

    foreach ($id in $oldIds) {
        try { Stop-Process -Id $id -Force }
        catch { Write-Log "ERROR: lghub_agent (PID $id) を終了できません: $($_.Exception.Message)"; return $false }
    }

    $newId = Wait-AgentReady -ExcludeIds $oldIds -TimeoutSeconds $AgentRestartTimeoutSeconds
    if ($newId) { Write-Log "lghub_agent が起動しました (PID: $newId)"; return $true }

    # tray が止まっている、または起動し直さなかった場合。LaunchGhub タスクなら元と同じ権限で tray を起動できる
    Write-Log "lghub_agent が起動しないため、$FallbackTaskName タスクを実行します"
    try { Start-ScheduledTask -TaskName $FallbackTaskName }
    catch { Write-Log "ERROR: $FallbackTaskName タスクを実行できません: $($_.Exception.Message)"; return $false }

    $newId = Wait-AgentReady -ExcludeIds $oldIds -TimeoutSeconds $AgentRestartTimeoutSeconds
    if ($newId) { Write-Log "lghub_agent が起動しました (PID: $newId)"; return $true }

    Write-Log "ERROR: lghub_agent が起動しませんでした"
    $false
}

function Invoke-ProfileCheck {
    param([string]$ExeName, [int]$DelaySeconds = 0)

    # agent が応答しない異常はゲームの状態に関係なく判定できるので、待機より先に確かめる。
    # スリープ復帰後は応答しなくなっていることがあり（実測）、ここで再起動すれば待機の間に復旧が済む。
    $autoSwitching = Get-AutoSwitchingEnabled
    if ($null -eq $autoSwitching) {
        Write-Log "lghub_agent が応答しません"
        if (-not (Restart-Agent)) { return }
        $autoSwitching = Get-AutoSwitchingEnabled
        if ($null -eq $autoSwitching) { Write-Log "ERROR: 再起動後も lghub_agent が応答しません"; return }
    }
    # オフのときはプロファイルが切り替わらないのが正常なので、不一致を異常とみなせない
    if (-not $autoSwitching) {
        Write-Log "G HUB の自動切替がオフのため、判定しません"
        return
    }

    if ($DelaySeconds -gt 0) {
        Write-Log "${DelaySeconds}秒後にプロファイルを確認します"
        Start-Sleep -Seconds $DelaySeconds
    }

    $game = Get-GameApplicationIds $ExeName
    if (-not $game.Responded) {
        Write-Log "ERROR: lghub_agent からアプリ一覧を取得できません"
        return
    }
    if ($game.Ids.Count -eq 0) {
        Write-Log "G HUB に $ExeName のアプリ登録が見つからないため、判定できません"
        return
    }

    $result = Wait-GameProfile -ExeName $ExeName -GameApplicationIds $game.Ids -TimeoutSeconds $ForegroundTimeoutSeconds
    switch ($result) {
        'Ok'      { Write-Log "$ExeName のプロファイルが適用されています"; return }
        'Exited'  { Write-Log "$ExeName が終了したため、判定を中止します"; return }
        'Timeout' { Write-Log "$ExeName が ${ForegroundTimeoutSeconds}秒以内に前面に来なかったため、判定を中止します"; return }
    }

    # 前面待ちの間に自動切替をオフにされた場合、不一致は正常
    if ((Get-AutoSwitchingEnabled) -eq $false) {
        Write-Log "G HUB の自動切替がオフになったため、再起動しません"
        return
    }

    if (-not (Restart-Agent)) { return }

    $result = Wait-GameProfile -ExeName $ExeName -GameApplicationIds $game.Ids -TimeoutSeconds $ForegroundTimeoutSeconds
    switch ($result) {
        'Ok'       { Write-Log "再起動後、$ExeName のプロファイルが適用されました" }
        'Mismatch' { Write-Log "ERROR: 再起動後も $ExeName のプロファイルが適用されません" }
        default    { Write-Log "再起動後の確認を中止しました ($result)" }
    }
}

if ($CheckOnce) {
    Invoke-ProfileCheck $CheckOnce
    return
}

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Log "ERROR: 常駐には管理者権限が必要です（Win32_ProcessStartTrace の購読のため）"
    exit 1
}

$filter = ($TargetProcesses | ForEach-Object { "ProcessName = '$_'" }) -join ' OR '
$query  = "SELECT * FROM Win32_ProcessStartTrace WHERE $filter"

$sourceId = 'GhubProfileWatcher'

Write-Log "監視を開始します: $($TargetProcesses -join ', ')"

try {
    Register-CimIndicationEvent -Query $query -SourceIdentifier $sourceId | Out-Null

    while ($true) {
        # 常駐が目的なので、一過性のエラー（agent の再起動中、ログの一時ロックなど）で
        # ループを抜けない。抜けると無言で監視が止まり、次のログオンまで復旧しない。
        try {
            $evt  = Wait-Event -SourceIdentifier $sourceId
            $name = $evt.SourceEventArgs.NewEvent.ProcessName
            Remove-Event -EventIdentifier $evt.EventIdentifier

            # ランチャー経由で1回の起動につき複数のイベントが届くが、抑止しない。
            # 判定は読み取りだけで、agent を再起動するのは応答しないか、プロファイルが本当に不一致のときに限るため、
            # 重複して判定しても害が無い。抑止すると、判定中に起動し直したセッションを取りこぼす。
            Write-Log "$name の起動を検知しました"
            Invoke-ProfileCheck $name -DelaySeconds $DelayBeforeCheck
        }
        catch {
            Write-Log "ERROR: $($_.Exception.Message)"
            Start-Sleep -Seconds 5
        }
    }
}
finally {
    Unregister-Event -SourceIdentifier $sourceId -ErrorAction SilentlyContinue
    Write-Log "監視を終了しました"
}
