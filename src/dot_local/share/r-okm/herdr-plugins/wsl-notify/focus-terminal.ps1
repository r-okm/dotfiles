# Brings the Windows Terminal tab named WSL, where herdr runs, to the front.
# Called by wsl-notify.py when a toast is clicked. Kept ASCII-only like toast.ps1.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes
Add-Type -Namespace R -Name User32 -MemberDefinition @'
[DllImport("user32.dll")] public static extern bool SetForegroundWindow(System.IntPtr hWnd);
[DllImport("user32.dll")] public static extern bool ShowWindow(System.IntPtr hWnd, int nCmdShow);
[DllImport("user32.dll")] public static extern bool IsIconic(System.IntPtr hWnd);
'@
$A = [System.Windows.Automation.AutomationElement]
$scope = [System.Windows.Automation.TreeScope]
$windows = $A::RootElement.FindAll($scope::Children,
  (New-Object System.Windows.Automation.PropertyCondition($A::ClassNameProperty, 'CASCADIA_HOSTING_WINDOW_CLASS')))
$wslTab = New-Object System.Windows.Automation.AndCondition(
  (New-Object System.Windows.Automation.PropertyCondition($A::ControlTypeProperty, [System.Windows.Automation.ControlType]::TabItem)),
  (New-Object System.Windows.Automation.PropertyCondition($A::NameProperty, 'WSL')))
foreach ($w in $windows) {
  $tab = $w.FindFirst($scope::Descendants, $wslTab)
  if (-not $tab) { continue }
  $h = [System.IntPtr]$w.Current.NativeWindowHandle
  $SW_RESTORE = 9
  if ([R.User32]::IsIconic($h)) { [void][R.User32]::ShowWindow($h, $SW_RESTORE) }
  # The protocol handler inherits the right to take the foreground from the toast click.
  [void][R.User32]::SetForegroundWindow($h)
  $tab.GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern).Select()
  exit 0
}
Write-Error 'No Windows Terminal tab named WSL'
