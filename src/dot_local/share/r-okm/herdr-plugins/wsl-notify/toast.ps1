# Shows a herdr notification as a Windows toast, called by wsl-notify.py.
# Kept ASCII-only: Windows PowerShell 5.1 reads BOM-less scripts in the ANSI code page.
param(
  # Base64 of UTF-8 JSON {title, body, launch, tag, expires?, quiet_if_front?}. expires
  # (epoch seconds) removes the toast from Action Center at that time; quiet_if_front skips
  # the toast while the WSL tab is in front. WSL interop drops double quotes from
  # arguments, so the text is not passed as-is.
  [Parameter(Mandatory)] [string]$Payload
)
$ErrorActionPreference = 'Stop'
$n = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Payload)) | ConvertFrom-Json

Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes
Add-Type -Namespace R -Name User32 -MemberDefinition @'
[DllImport("user32.dll")] public static extern System.IntPtr GetForegroundWindow();
[DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(System.IntPtr hWnd, out uint pid);
'@

# herdr runs in the Windows Terminal tab named WSL (fixed by the profile's tabTitle).
# With quiet_if_front, stay quiet while that tab is the one in front.
$fg = [R.User32]::GetForegroundWindow()
$fgPid = 0
[void][R.User32]::GetWindowThreadProcessId($fg, [ref]$fgPid)
if ($n.quiet_if_front -and (Get-Process -Id $fgPid -ErrorAction SilentlyContinue).ProcessName -like 'WindowsTerminal*') {
  $A = [System.Windows.Automation.AutomationElement]
  $selectedTab = New-Object System.Windows.Automation.AndCondition(
    (New-Object System.Windows.Automation.PropertyCondition($A::ControlTypeProperty, [System.Windows.Automation.ControlType]::TabItem)),
    (New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.SelectionItemPattern]::IsSelectedProperty, $true)))
  $tab = $A::FromHandle($fg).FindFirst([System.Windows.Automation.TreeScope]::Descendants, $selectedTab)
  if ($tab -and $tab.Current.Name -eq 'WSL') { exit 0 }
}

[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null
$esc = { param($s) [Security.SecurityElement]::Escape([string]$s) }
$xml = [Windows.Data.Xml.Dom.XmlDocument]::new()
# Protocol activation sends clicks to the herdr-wsl: handler. A plain toast would activate
# the AUMID's COM server, which belongs to Windows herdr.
$xml.LoadXml(
  '<toast activationType="protocol" launch="' + (& $esc $n.launch) + '">' +
  '<visual><binding template="ToastGeneric">' +
  '<text>' + (& $esc $n.title) + '</text><text>' + (& $esc $n.body) + '</text>' +
  '</binding></visual></toast>')
$toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
# A newer toast with the same tag replaces the older one. The caller picks the tag, so a
# pane's status toasts and its prompt-cache toasts replace only their own kind.
$toast.Group = 'herdr-wsl'
$toast.Tag = $n.tag
if ($n.expires) { $toast.ExpirationTime = [DateTimeOffset]::FromUnixTimeSeconds([long]$n.expires) }

# Windows herdr registers Herdr.Desktop, which shows the toast as coming from Herdr.
$aumid = 'Herdr.Desktop'
if (-not (Test-Path "HKCU:\Software\Classes\AppUserModelId\$aumid")) {
  $aumid = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
}
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($aumid).Show($toast)
