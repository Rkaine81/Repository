$ApplicationName = "7-Zip 22.00 (x64 edition)"
$InstalledApps = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*$ApplicationName*" }
$InstalledApps

Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000001}"

Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000022}"


$ApplicationName = "7-Zip"
Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*$ApplicationName*" }