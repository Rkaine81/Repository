# Define the start date for log search
$startDate = (Get-Date).AddDays(-7) # Search logs from the past 7 days
# Get the event logs related to system reboots
$eventLogs = Get-WinEvent -FilterHashtable @{
   LogName = 'System'
   StartTime = $startDate
   ID = 6008, 1074, 41
}
# Display the results
foreach ($event in $eventLogs) {
   Write-Host "Time: $($event.TimeCreated)"
   Write-Host "Event ID: $($event.Id)"
   Write-Host "Message: $($event.Message)"
   Write-Host ""
}
Write-Host "Reboot analysis completed."