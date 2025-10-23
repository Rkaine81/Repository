# Path to save the log
$logPath = "C:\GPUpdateTracker\gpupdate_tracker.log"
if (!(Test-Path "C:\GPUpdateTracker")) {
   New-Item -ItemType Directory -Path "C:\GPUpdateTracker" | Out-Null
}
# Start a WMI event watcher
Register-WmiEvent -Query "SELECT * FROM __InstanceCreationEvent WITHIN 5 WHERE TargetInstance ISA 'Win32_Process' AND TargetInstance.Name = 'gpupdate.exe'" -Action {
   $process = $Event.SourceEventArgs.NewEvent.TargetInstance
   $parent = Get-CimInstance Win32_Process -Filter "ProcessId = $($process.ParentProcessId)" | Select-Object -ExpandProperty Name
   $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
   $entry = "$timestamp - gpupdate.exe started. Parent process: $parent (PID: $($process.ParentProcessId))"
   Add-Content -Path $using:logPath -Value $entry
}
Write-Host "GPUpdate Tracker is running. Logging to: $logPath"