# ghub-tools

Logicool G HUB の常駐プロセス `lghub_agent.exe` が応答しなくなったとき、それを検知して再起動するためのスクリプト群。

agent はスリープ復帰後に、プロセスが生きたまま WebSocket（`ws://127.0.0.1:9010`）の待ち受けをすべて閉じることがある。
この状態は自然には直らず、G HUB の UI はスプラッシュ画面から進まず、アプリ別プロファイルも切り替わらない。
agent を強制終了すると `lghub_system_tray.exe` が数秒で新しい agent を起動し直し、それで復旧する。
ここにあるスクリプトは、この再起動を自動で行う。

## スクリプトと運用状況

| スクリプト | タスク名 | 動作 | 状態 |
| --- | --- | --- | --- |
| `ghub-resume-recovery.ps1` | `GhubResumeRecovery` | スリープ復帰時に起動し、agent が30秒間一度も応答しなければ再起動する | 稼働中 |
| `ghub-profile-watcher.ps1` | `GhubProfileWatcher` | 常駐して原神の起動を検知し、agent が応答しないか、アプリ別プロファイルが適用されていなければ再起動する | 停止中（保管） |
| `ghub-agent-monitor.ps1` | `GhubAgentMonitor` | 常駐して30秒ごとに agent の疎通を記録する。agent には何もしない | 停止中（保管） |

現在は `ghub-resume-recovery.ps1` だけで運用している。
これまでに観測した不具合はどれもスリープ復帰の直後から起きており、復帰時の確認だけで拾えたためである。
停止中の2つは、スリープと関係のない不具合が出たときや、原因を調べ直すときに使う。

各スクリプトのログは `%LOCALAPPDATA%` 直下に、スクリプトと同じ名前（拡張子 `.log`）で書き出される。

## 配置と更新

このディレクトリは chezmoi の `src/AppData/Local/ghub-tools/` で管理しており、Windows 側で `chezmoi apply` を実行すると `%LOCALAPPDATA%\ghub-tools\` に配置される。
Linux では `AppData` が `.chezmoiignore` で除外されているため、配置されない。

`chezmoi apply` は、必ずこのディレクトリに対象を絞って実行する。
`AppData` の下には Windows Terminal の `settings.json` のように Windows 側が正本のファイルもあり、対象を絞らずに適用すると、それらを source の内容で上書きしうるためである。

```powershell
chezmoi diff --recursive ~/AppData/Local/ghub-tools
chezmoi apply ~/AppData/Local/ghub-tools
```

`chezmoi diff` は、ディレクトリを指定しても `--recursive` を付けないと中のファイルを比べない。
`chezmoi apply` は既定で中まで適用する。

スクリプトを更新したとき、`GhubResumeRecovery` は次のスリープ復帰から新しい版で動く。
常駐する2つは起動中の版が動き続けるので、タスクを止めて起動し直す（手順は各タスクの節にある）。

## タスクの登録と解除

タスクはどれも手動で登録する。
以下のコマンドは、ログオンしているユーザー自身のタスクとして登録する。

`GhubResumeRecovery` と `GhubAgentMonitor` は、`powershell.exe` を直接起動せずに `conhost.exe --headless` を挟む。
既定のターミナルが Windows Terminal のとき、管理者権限なしで起動したコンソールは Windows Terminal に渡され、`-WindowStyle Hidden` を付けてもウィンドウが残るためである。
管理者権限で動くタスク（`GhubProfileWatcher`）はこの受け渡しが起きないので、`powershell.exe` を直接起動する。

### GhubResumeRecovery（稼働中）

スリープ・休止状態からの復帰イベント（System ログ、`Microsoft-Windows-Power-Troubleshooter`、イベント ID 1）で起動する。
G HUB はスタートアップから管理者権限なしで動いており、その agent は管理者権限なしで終了できるので、タスクも管理者権限なしで動かす。

登録（通常の PowerShell）:

```powershell
$script = "$env:LOCALAPPDATA\ghub-tools\ghub-resume-recovery.ps1"
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
```

解除:

```powershell
Unregister-ScheduledTask -TaskName 'GhubResumeRecovery' -Confirm:$false
```

### GhubProfileWatcher（停止中）

ログオン時に起動して常駐する。
プロセスの起動を検知する `Win32_ProcessStartTrace` の購読に管理者権限が要るため、管理者権限で動かす。
監視対象のゲームは、スクリプト冒頭の `$TargetProcesses` で指定する。

登録（管理者の PowerShell）:

```powershell
$script = "$env:LOCALAPPDATA\ghub-tools\ghub-profile-watcher.ps1"
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
Start-ScheduledTask -TaskName 'GhubProfileWatcher'
```

`-ExecutionTimeLimit 0` がないと、既定の3日で強制終了されて常駐が止まる。
`$trigger.Delay` は、ログオン直後に G HUB 本体が起動するのを待つための余裕である。

起動し直し（スクリプトの更新後。管理者の PowerShell）:

```powershell
Stop-ScheduledTask -TaskName 'GhubProfileWatcher'; Start-ScheduledTask -TaskName 'GhubProfileWatcher'
```

解除（管理者の PowerShell）:

```powershell
Stop-ScheduledTask -TaskName 'GhubProfileWatcher'
Unregister-ScheduledTask -TaskName 'GhubProfileWatcher' -Confirm:$false
```

常駐させずに1回だけ判定するには、`-CheckOnce` に exe 名を渡す。
イベントを購読しないので、管理者権限は要らない。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\ghub-tools\ghub-profile-watcher.ps1" -CheckOnce GenshinImpact.exe
```

### GhubAgentMonitor（停止中）

ログオン時に起動して常駐する。
agent には何もしないので、管理者権限なしで動かす。

登録（通常の PowerShell）:

```powershell
$script = "$env:LOCALAPPDATA\ghub-tools\ghub-agent-monitor.ps1"
$user   = "$env:USERDOMAIN\$env:USERNAME"

$action    = New-ScheduledTaskAction -Execute 'conhost.exe' `
                 -Argument "--headless powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$script`""
$trigger   = New-ScheduledTaskTrigger -AtLogOn -User $user
$principal = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Limited
$settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
                 -ExecutionTimeLimit 0 -MultipleInstances IgnoreNew

Register-ScheduledTask -TaskName 'GhubAgentMonitor' -Action $action -Trigger $trigger `
                       -Principal $principal -Settings $settings
Start-ScheduledTask -TaskName 'GhubAgentMonitor'
```

`Stop-ScheduledTask` が終了させるのはタスクが起動した `conhost.exe` だけで、その下の `powershell.exe` は残る。
そのためスクリプト側で親プロセスの終了を監視しており、止めてから最長30秒で終了する。
起動し直すときは、止めてから30秒以上待つ。

```powershell
Stop-ScheduledTask -TaskName 'GhubAgentMonitor'; Start-Sleep 35; Start-ScheduledTask -TaskName 'GhubAgentMonitor'
```

解除:

```powershell
Stop-ScheduledTask -TaskName 'GhubAgentMonitor'
Unregister-ScheduledTask -TaskName 'GhubAgentMonitor' -Confirm:$false
```

## 状態の確認

登録されているタスクと状態:

```powershell
Get-ScheduledTask | Where-Object TaskName -match 'Ghub' | Format-Table TaskName, State
```

ログの末尾:

```powershell
Get-Content "$env:LOCALAPPDATA\ghub-resume-recovery.log" -Tail 20
```

`GhubResumeRecovery` のログは、復帰ごとに次のどちらかになる。

- agent が固まっていなかった場合: `agent は応答しています`
- 固まっていて再起動した場合: `agent が 30秒間応答しません` → `lghub_agent を再起動します` → `lghub_agent が起動しました`

`ERROR: lghub_agent が起動しませんでした` が出た場合は、tray が新しい agent を起動し直していない。
G HUB を手動で起動する。
