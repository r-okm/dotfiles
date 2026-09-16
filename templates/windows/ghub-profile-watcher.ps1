<#
.SYNOPSIS
    対象ゲームの起動を検知し、G HUB の UI を一時的に開いてプロファイル再スキャンを強制する。

.DESCRIPTION
    G HUB の lghub_agent.exe は、時間経過やスリープ復帰によってプロセス監視が停止し、
    ゲーム起動時のアプリ別プロファイル切替を取りこぼすことがある。
    UI (lghub.exe) を起動すると実行中プロセスの再スキャンが走って復旧するため、
    その操作を自動化する。

    Win32_ProcessStartTrace の購読には管理者権限が必要。
    タスクスケジューラで「最上位の特権で実行する」を有効にして起動すること。

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

#Requires -RunAsAdministrator

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---- 設定 -------------------------------------------------------------

# 監視対象の実行ファイル名。複数指定可。
$TargetProcesses = @(
    'GenshinImpact.exe'
)

# G HUB の UI 実行ファイル
$LghubUiPath = 'C:\Program Files\LGHUB\lghub.exe'

# ゲーム起動を検知してから UI を開くまでの待機秒数。
# アンチチートのロードが終わる前に再スキャンしても意味がないため、短すぎると効かない。
$DelayBeforeRescan = 25

# UI を開いてから閉じるまでの秒数。再スキャンが完了するのに十分な時間を取る。
# 0 にすると閉じずに開いたままにする。
$UiVisibleSeconds = 10

# 直前の再スキャンから、同一ゲームの再検知を抑止する秒数（ランチャー経由の多重起動対策）
$CooldownSeconds = 120

$LogPath = Join-Path $env:LOCALAPPDATA 'ghub-profile-watcher.log'

# ---- 実装 -------------------------------------------------------------

function Write-Log {
    param([string]$Message)
    $line = '{0}  {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    Add-Content -Path $LogPath -Value $line -Encoding UTF8
}

function Get-LghubUiPids {
    Get-Process -Name 'lghub' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Id
}

function Invoke-GhubRescan {
    if (-not (Test-Path $LghubUiPath)) {
        Write-Log "ERROR: G HUB UI が見つかりません: $LghubUiPath"
        return
    }

    # 関数の戻り値はパイプラインで展開されるので、@() で配列に戻さないと空のとき $null になる
    $before = @(Get-LghubUiPids)

    # UI は単一インスタンスなので、既に開いていると Start-Process は既存ウィンドウを
    # 前に出すだけで再スキャンが走らない。ユーザーが開いている UI を閉じないよう何もしない。
    if ($before.Count -gt 0) {
        Write-Log "G HUB UI は既に起動しているため、何もしません"
        return
    }

    Write-Log "G HUB UI を起動します"
    Start-Process -FilePath $LghubUiPath | Out-Null

    if ($UiVisibleSeconds -gt 0) {
        Start-Sleep -Seconds $UiVisibleSeconds

        # Electron はレンダラーを子プロセスとして持つため、PID の差分でまとめて閉じる
        $spawned = @(Get-LghubUiPids | Where-Object { $_ -notin $before })
        if ($spawned.Count -gt 0) {
            Stop-Process -Id $spawned -Force -ErrorAction SilentlyContinue
            Write-Log "G HUB UI を閉じました"
        }
    }
}

$filter = ($TargetProcesses | ForEach-Object { "ProcessName = '$_'" }) -join ' OR '
$query  = "SELECT * FROM Win32_ProcessStartTrace WHERE $filter"

$sourceId  = 'GhubProfileWatcher'
$lastFired = @{}

Write-Log "監視を開始します: $($TargetProcesses -join ', ')"

try {
    Register-CimIndicationEvent -Query $query -SourceIdentifier $sourceId | Out-Null

    while ($true) {
        # 常駐が目的なので、一過性のエラー（更新中の UI 起動失敗、ログの一時ロックなど）で
        # ループを抜けない。抜けると無言で監視が止まり、次のログオンまで復旧しない。
        try {
            $evt  = Wait-Event -SourceIdentifier $sourceId
            $name = $evt.SourceEventArgs.NewEvent.ProcessName
            Remove-Event -EventIdentifier $evt.EventIdentifier

            if ($lastFired.ContainsKey($name) -and
                ((Get-Date) - $lastFired[$name]).TotalSeconds -lt $CooldownSeconds) {
                Write-Log "$name を検知しましたが、クールダウン中のためスキップします"
                continue
            }

            Write-Log "$name の起動を検知しました。${DelayBeforeRescan}秒後に G HUB UI を起動します"
            Start-Sleep -Seconds $DelayBeforeRescan

            if (-not (Get-Process -Name ([IO.Path]::GetFileNameWithoutExtension($name)) -ErrorAction SilentlyContinue)) {
                Write-Log "$name は既に終了しているため、G HUB UI は起動しません"
                continue
            }

            Invoke-GhubRescan

            # 再スキャンを実行したときだけ記録する。中止した分でクールダウンを消費すると、
            # 起動し直した本番のセッションを取りこぼす。
            $lastFired[$name] = Get-Date
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
