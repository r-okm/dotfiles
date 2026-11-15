# ghub-tools

Logicool G HUB の常駐プロセス `lghub_agent.exe` が応答しなくなったとき、それを検知して再起動するためのスクリプト群。

agent はスリープ復帰後に、プロセスが生きたまま WebSocket（`ws://127.0.0.1:9010`）の待ち受けをすべて閉じることがある。
この状態は自然には直らず、G HUB の UI はスプラッシュ画面から進まず、アプリ別プロファイルも切り替わらない。
agent を強制終了すると `lghub_system_tray.exe` が新しい agent を起動し直し、それで復旧する。
ここにあるスクリプトは、この再起動を自動で行う。

これとは別に、agent が応答していて自動切替もオンなのに、ゲームを起動してもプロファイルがデスクトップのまま切り替わらないことがある（2026-11-14 に発生。G HUB の UI を起動したら切り替わった）。
こちらは原因が分かっていないので、起きた時刻と状況を記録している。

## スクリプトと運用状況

| スクリプト | タスク名 | 状態 | 常駐 | 起動のきっかけ | 管理者権限 | 動作 |
| --- | --- | --- | --- | --- | --- | --- |
| `ghub-resume-recovery.ps1` | `GhubResumeRecovery` | 稼働中 | しない | タスクスケジューラー（スリープ・休止状態からの復帰イベント） | 不要 | agent が30秒間一度も応答しなければ再起動する |
| `ghub-agent-monitor.ps1` | `GhubAgentMonitor` | 稼働中 | する | タスクスケジューラー（ログオン） | 不要 | agent の疎通と、アプリ別プロファイルの切り替わりを記録する。agent には何もしない |
| `ghub-profile-watcher.ps1` | `GhubProfileWatcher` | 停止中（保管） | する | タスクスケジューラー（ログオン） | 必要 | 原神の起動を検知し、agent が応答しないか、アプリ別プロファイルが適用されていなければ再起動する |

agent の再起動は `ghub-resume-recovery.ps1` だけが行う。
agent が固まる不具合はどれもスリープ復帰の直後から起きており、復帰時の確認で拾えている。
プロファイルが切り替わらない不具合は agent が応答しているので、復帰時の確認では拾えず、`ghub-agent-monitor.ps1` で記録している。
`ghub-profile-watcher.ps1` は、プロファイルの不一致を見つけたら agent を再起動する。
不一致を自動で直すと決めたときに使う。

各スクリプトのログは、スクリプトと同じディレクトリに、スクリプトと同じ名前（拡張子 `.log`）で書き出される。
ログは chezmoi の管理対象ではないので、`chezmoi apply` で消えたり上書きされたりすることはない。

## 配置と更新

このディレクトリは chezmoi の `src/AppData/Local/r-okm/ghub-tools/` で管理しており、Windows 側で `chezmoi apply` を実行すると `%LOCALAPPDATA%\r-okm\ghub-tools\` に配置される。
Linux では `AppData` が `.chezmoiignore` で除外されているため、配置されない。

`chezmoi apply` は、必ずこのディレクトリに対象を絞って実行する。
`AppData` の下には Windows Terminal の `settings.json` のように Windows 側が正本のファイルもあり、対象を絞らずに適用すると、それらを source の内容で上書きしうるためである。

```powershell
chezmoi diff --recursive ~/AppData/Local/r-okm/ghub-tools
chezmoi apply ~/AppData/Local/r-okm/ghub-tools
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
$script = "$env:LOCALAPPDATA\r-okm\ghub-tools\ghub-resume-recovery.ps1"
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
$script = "$env:LOCALAPPDATA\r-okm\ghub-tools\ghub-profile-watcher.ps1"
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
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\r-okm\ghub-tools\ghub-profile-watcher.ps1" -CheckOnce GenshinImpact.exe
```

### GhubAgentMonitor（稼働中）

ログオン時に起動して常駐する。
agent には何もしないので、管理者権限なしで動かす。
確認の間隔は30秒で、原神の実行中だけ2秒にする。前面に来てから数秒で切り替わったかを見分けるためである。
監視するゲームはスクリプトの引数 `-GameProcesses` で指定する（既定は `GenshinImpact`）。
複数のゲームはカンマで区切って渡す（例: `-GameProcesses GenshinImpact,StarRail`）。

登録（通常の PowerShell）:

```powershell
$script = "$env:LOCALAPPDATA\r-okm\ghub-tools\ghub-agent-monitor.ps1"
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
Get-Content "$env:LOCALAPPDATA\r-okm\ghub-tools\ghub-resume-recovery.log" -Tail 20
Get-Content "$env:LOCALAPPDATA\r-okm\ghub-tools\ghub-agent-monitor.log" -Tail 20
```

`GhubResumeRecovery` のログは、復帰ごとに次のどちらかになる。

- agent が固まっていなかった場合: `agent は応答しています`
- 固まっていて再起動した場合: `agent が 30秒間応答しません` → `lghub_agent を再起動します` → `lghub_agent が起動しました`

`30秒以内に新しい agent が応答しないため、tray を再起動します` が出た場合は、末尾の `新しい agent:` で状況を見分ける。

- `新しい agent: なし`: tray が agent を起動し直さなかった。tray が動いたまま起動し直さない状態になっていた可能性がある。
- `新しい agent: <PID>`: tray は起動し直していたが、agent の応答が遅かった。

スクリプトは tray を再起動し、そのあとに `lghub_agent が起動しました` が続く。
tray は起動時に agent がいなければ自分で起動し、動いている agent には手を出さない。再起動した tray は次の回から agent を起動し直す。

`ERROR: lghub_agent が起動しませんでした` が出た場合は、tray を再起動しても agent が応答しなかった。
G HUB を手動で起動する。

`GhubAgentMonitor` のログ（`ghub-agent-monitor.log`）は、状態が変わったときだけ書かれる。
プロファイルが切り替わらなかったときは、次の行を見る。

- `不一致: …`: 原神が前面にあるのに、5秒たってもプロファイルが一致しなかった。監視を始めたときに原神がすでに前面にあった場合は、前面にあった秒数を「監視の開始時から前面のまま<秒数>秒」と書く。続く項目で、原因が次のどれかを見分ける。
  - `有効なプロファイル = 取得できず（…）`: agent が応答していない。
  - `自動切替 = オフ`: 設定がオフなので、切り替わらないのが正常。
  - どちらでもない: agent が応答し、自動切替もオンなのに切り替えていない。
  - 項目の `起動から<秒数>秒` が小さく、すぐあとに一致していれば、agent が起動直後のゲームを見つけるのに時間がかかっただけで、不具合ではない。
- `有効なプロファイル: …（…、不一致の記録から<秒数>秒後）` または `一致しました: …`: 不一致のあと、ゲームのプロファイルに切り替わった。直前に `lghub が起動しました` があれば、UI を起動した直後に切り替わった。

行末の `agent=<PID>（起動 …）` を `ghub-resume-recovery.log` の PID と照らし合わせると、その agent がいつのスリープ復帰で起動したものかが分かる。
