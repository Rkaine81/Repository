Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$form = New-Object System.Windows.Forms.Form
$form.Text = "System Status"
$form.Size = New-Object System.Drawing.Size(320,280)
$form.StartPosition = "Manual"
$form.Location = New-Object System.Drawing.Point(10,10)
$form.TopMost = $true
$form.FormBorderStyle = 'FixedToolWindow'
$label = New-Object System.Windows.Forms.Label
$label.Size = New-Object System.Drawing.Size(200, 120)
$label.Location = New-Object System.Drawing.Point(10,10)
$label.Font = New-Object System.Drawing.Font("Consolas", 9)
$form.Controls.Add($label)
$button = New-Object System.Windows.Forms.Button
$button.Text = "Fix My Device"
$button.Location = New-Object System.Drawing.Point(50, 130)
$button.Size = New-Object System.Drawing.Size(100, 30)
$button.Add_Click({
   $cmd = 'Write-Host "Insert your fix logic here"'
   Start-Process "powershell.exe" -ArgumentList "-NoProfile -WindowStyle Hidden -Command `$cmd" -Verb RunAs
})
$form.Controls.Add($button)
function Get-SystemInfo {
   $uptime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
   $uptimeStr = ((Get-Date) - $uptime).ToString("dd\.hh\:mm")
   $bitLocker = (Get-BitLockerVolume -MountPoint "C:").VolumeStatus
$status = @"
User: $env:USERNAME
Device: $env:COMPUTERNAME
Uptime: $uptimeStr
BitLocker: $bitLocker
"@
   return $status
}
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 60000 # 1 minute refresh
$timer.Add_Tick({ $label.Text = Get-SystemInfo })
$timer.Start()
$label.Text = Get-SystemInfo
[void]$form.ShowDialog()