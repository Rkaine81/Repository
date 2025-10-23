# Define the number of reboots you want to retrieve
$numberOfReboots = 3

# Retrieve the events from the System log where the event ID is 6006 (shutdown)
$shutdownEvents = Get-EventLog -LogName System -InstanceId 6006 | Select-Object -First $numberOfReboots

# Retrieve the events from the System log where the event ID is 6005 (startup)
$startupEvents = Get-EventLog -LogName System -InstanceId 6005 | Select-Object -First $numberOfReboots

# Combine and sort the events by time
$events = $shutdownEvents + $startupEvents | Sort-Object -Property TimeGenerated -Descending

# Group events into pairs of shutdown/startup
$rebootPairs = @()
for ($i = 0; $i -lt $events.Count - 1; $i++) {
    if ($events[$i].EventID -eq 6005 -and $events[$i + 1].EventID -eq 6006) {
        $rebootPairs += [PSCustomObject]@{
            ShutdownTime = $events[$i + 1].TimeGenerated
            StartupTime  = $events[$i].TimeGenerated
            Duration     = $events[$i].TimeGenerated - $events[$i + 1].TimeGenerated
        }
    }
}

# Display the last three reboots
$rebootPairs | Select-Object -First $numberOfReboots | Format-Table -AutoSize