# Keep the WSL VM running from logon, so the nvim launcher from 303 does not
# pay for a VM boot after WSL idled out.
#
# vmIdleTimeout=-1 in .wslconfig is reported to be ignored by some WSL
# releases; a live process in the default distribution keeps it up on all of
# them. conhost --headless gives that process a console without a window.
# Nothing restarts the keeper after wsl --shutdown until the next logon; run
# Start-ScheduledTask -TaskName 'r-okm WSL keepalive' to bring it back.
# MultipleInstances IgnoreNew makes a start while it runs harmless.

$ErrorActionPreference = 'Stop'

$taskName = 'r-okm WSL keepalive'
$user = "$env:USERDOMAIN\$env:USERNAME"

$action = New-ScheduledTaskAction -Execute 'conhost.exe' `
  -Argument '--headless wsl.exe -e sleep infinity'
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $user
$principal = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
  -ExecutionTimeLimit 0 -MultipleInstances IgnoreNew

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger `
  -Principal $principal -Settings $settings -Force | Out-Null
Start-ScheduledTask -TaskName $taskName

Write-Host "WSL keepalive: scheduled task '$taskName' registered and started"
