# Define output directory and log file path
$outputDir = "C:\CHOA\DeviceHealthLogs"
if (-Not (Test-Path $outputDir)) {
   New-Item -Path $outputDir -ItemType Directory
}

$logFile = "$outputDir\DeviceHealthLogs.zip"

# Logging function
function Write-Log {
   param (
       [string]$message,
       [string]$logFile = "$outputDir\ScriptLog.txt"
   )
   # Ensure the log directory exists
   $logDir = Split-Path $logFile
   if (-Not (Test-Path $logDir)) {
       New-Item -Path $logDir -ItemType Directory
   }
   # Format the log entry
   $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
   $logEntry = "$timestamp - $message"
   # Append the log entry to the log file
   Add-Content -Path $logFile -Value $logEntry
}
# Function to gather event logs
function Gather-EventLog {
   param (
       [string]$logName,
       [string]$logPath
   )
   Write-Log -message "Gathering $logName Event Log."
   if (Test-Path $logPath) {
       Remove-Item $logPath -Force
   }
   wevtutil epl $logName $logPath
}
# Gather System Event Logs
Gather-EventLog -logName "System" -logPath "$outputDir\SystemEventLog.evtx"
# Gather Application Event Logs
Gather-EventLog -logName "Application" -logPath "$outputDir\ApplicationEventLog.evtx"
# Gather Security Event Logs
Gather-EventLog -logName "Security" -logPath "$outputDir\SecurityEventLog.evtx"
# Gather System Information
$systemInfo = "$outputDir\SystemInfo.txt"
Write-Log -message "Gathering System Information."
systeminfo > $systemInfo
# Gather Installed Programs List
$programsList = "$outputDir\InstalledPrograms.txt"
Write-Log -message "Gathering Installed Programs List."
Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table –AutoSize > $programsList
# Gather Network Configuration
$networkConfig = "$outputDir\NetworkConfig.txt"
Write-Log -message "Gathering Network Configuration."
ipconfig /all > $networkConfig
# Gather Disk Information
$diskInfo = "$outputDir\DiskInfo.txt"
Write-Log -message "Gathering Disk Information."
Get-PhysicalDisk | Select-Object DeviceID, MediaType, OperationalStatus, Size | Format-Table -AutoSize > $diskInfo
# Gather Windows Update Log
$windowsUpdateLog = "$outputDir\WindowsUpdateLog.txt"
Write-Log -message "Gathering Windows Update Log."
Get-WindowsUpdateLog -LogPath $windowsUpdateLog
# Gather Driver Information
$driverInfo = "$outputDir\DriverInfo.txt"
Write-Log -message "Gathering Driver Information."
driverquery /v > $driverInfo
# Gather System Boot Time
$bootTime = "$outputDir\BootTime.txt"
Write-Log -message "Gathering System Boot Time."
systeminfo | find "Boot Time" > $bootTime
# Gather Windows Defender Logs (if applicable)
$defenderLog = "$outputDir\DefenderLog.txt"
Write-Log -message "Gathering Windows Defender Logs."
Get-WinEvent -LogName "Microsoft-Windows-Windows Defender/Operational" | Select-Object TimeCreated, Id, LevelDisplayName, Message | Format-Table -AutoSize > $defenderLog
# Gather Application Crashes from Event Logs
$appCrashes = "$outputDir\ApplicationCrashes.csv"
Write-Log -message "Gathering Application Crashes from Event Logs."
Get-WinEvent -LogName Application -FilterXPath "*[System[Level=2]]" | Where-Object { $_.ProviderName -eq "Application Error" } | Select-Object TimeCreated, ProviderName, Id, LevelDisplayName, Message | Export-Csv -Path $appCrashes -NoTypeInformation
# Gather Microsoft Endpoint Configuration Manager Client Logs modified in the last 24 hours
$mecmLogDir = "$outputDir\MECMLogs"
Write-Log -message "Gathering Microsoft Endpoint Configuration Manager Client Logs."
if (-Not (Test-Path $mecmLogDir)) {
   New-Item -Path $mecmLogDir -ItemType Directory
}
$logFiles = Get-ChildItem -Path "C:\Windows\CCM\Logs" -Recurse | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-1) }
foreach ($logFile in $logFiles) {
   Copy-Item -Path $logFile.FullName -Destination $mecmLogDir -Force
}
