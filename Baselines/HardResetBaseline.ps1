# Define the time window to search for hard resets (e.g., the last 24 hours)
$timeWindow = (Get-Date).AddDays(-1)
# Query the System event log for Kernel-Power events with Event ID 41
$hardResetEvents = Get-EventLog -LogName System | Where-Object {
   $_.EventID -eq 41 -and $_.Source -eq 'Microsoft-Windows-Kernel-Power' -and $_.TimeGenerated -ge $timeWindow
}
# Check if any hard reset events were found
if ($hardResetEvents.Count -gt 0) {
   Write-Output "Hard reset(s) detected in the last 24 hours:"
   foreach ($event in $hardResetEvents) {
       $eventDetails = @{
           TimeCreated = $event.TimeGenerated
           MachineName = $event.MachineName
           Message = $event.Message
       }
       #Write-Output $eventDetails
       return $false
   }
} else {
   #Write-Output "No hard resets detected in the last 24 hours."
   return $true
}