# Ensure BurntToast module is imported
Import-Module -Name BurntToast
# Function to check if a service is not disabled
function Check-Service-NotDisabled {
   param (
       [string]$serviceName
   )
   $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
   if ($service.StartType -ne 'Disabled') {
       return 1
   } else {
       return 0
   }
}
# Function to check if a service is running
function Check-Service-Running {
   param (
       [string]$serviceName
   )
   $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
   if ($service.Status -eq 'Running') {
       return 1
   } else {
       return 0
   }
}
# Function to check disk space
function Check-DiskSpace {
   $threshold = 20 # 20% free space threshold
   #$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match "^[a-zA-Z]:" }
   $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -eq "C:\" }
   $score = 0
   foreach ($drive in $drives) {
       $freeSpacePercent = ($drive.Free / $drive.Used) * 100
       if ($freeSpacePercent -gt $threshold) {
           $score += 1
       }
   }
   $maxScore = $drives.Count
   return @($score, $maxScore)
}
# Function to check CPU utilization
function Check-CPUUtilization {
   $cpu = Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -Average | Select-Object -ExpandProperty Average
   $score = 0
   if ($cpu -lt 80) {
       $score = 1
   }
   $maxScore = 1
   return @($score, $maxScore)
}
# Function to check memory utilization
function Check-MemoryUtilization {
   $memory = Get-WmiObject win32_operatingsystem
   $freeMemory = $memory.FreePhysicalMemory
   $totalMemory = $memory.TotalVisibleMemorySize
   $usedMemoryPercent = (($totalMemory - $freeMemory) / $totalMemory) * 100
   $score = 0
   if ($usedMemoryPercent -lt 80) {
       $score = 1
   }
   $maxScore = 1
   return @($score, $maxScore)
}
# Function to check for application crashes and other errors in event logs
function Check-EventLogs {
   $last24Hours = (Get-Date).AddHours(-24)
   $appErrors = Get-EventLog -LogName Application -After $last24Hours | Where-Object { $_.EntryType -eq "Error" }
   $sysErrors = Get-EventLog -LogName System -After $last24Hours | Where-Object { $_.EntryType -eq "Error" }
   $appCrashCount = $appErrors.Count
   $sysErrorCount = $sysErrors.Count
   $totalErrors = $appCrashCount + $sysErrorCount
   $score = 0
   if ($totalErrors -eq 0) {
       $score = 1
   }
   $maxScore = 1
   return @($score, $maxScore)
}
# Function to check Configuration Manager
function Check-ConfigMgr {
   $configMgrServiceStatus = Check-Service-NotDisabled -serviceName "CcmExec"
   $score = $configMgrServiceStatus
   $maxScore = 1
   return @($score, $maxScore)
}
# Function to check for pending reboots
function Check-PendingReboot {
   $rebootRequired = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired' -ErrorAction SilentlyContinue) -ne $null
   $score = $rebootRequired ? 0 : 1
   $maxScore = 1
   return @($score, $maxScore)
}

# Main script
$totalScore = 0
$maxScore = 0
# Check if key services are not disabled
$servicesToCheckNotDisabled = @("wuauserv", "BITS", "WinDefend", "CcmExec")
$serviceScoresNotDisabled = 0
foreach ($service in $servicesToCheckNotDisabled) {
   $serviceStatus = Check-Service-NotDisabled -serviceName $service
   $serviceScoresNotDisabled += $serviceStatus
   $totalScore += $serviceStatus
   $maxScore += 1
}
$serviceNotDisabledScore = "Service Not Disabled Score: $serviceScoresNotDisabled/$($servicesToCheckNotDisabled.Count)"
# Check if key services are running
$servicesToCheckRunning = @("BrokerInfrastructure", "CryptSvc", "DcomLaunch", "wlidsvc", "swprv", "RpcEptMapper", "WinRM")
$serviceScoresRunning = 0
foreach ($service in $servicesToCheckRunning) {
   $serviceStatus = Check-Service-Running -serviceName $service
   $serviceScoresRunning += $serviceStatus
   $totalScore += $serviceStatus
   $maxScore += 1
}
$serviceRunningScore = "Service Running Score: $serviceScoresRunning/$($servicesToCheckRunning.Count)"
# Check disk space
$diskResult = Check-DiskSpace
$diskScore = "Disk Space Score: $($diskResult[0])/$($diskResult[1])"
$totalScore += $diskResult[0]
$maxScore += $diskResult[1]
# Check CPU utilization
$cpuResult = Check-CPUUtilization
$cpuScore = "CPU Utilization Score: $($cpuResult[0])/$($cpuResult[1])"
$totalScore += $cpuResult[0]
$maxScore += $cpuResult[1]
# Check memory utilization
$memoryResult = Check-MemoryUtilization
$memoryScore = "Memory Utilization Score: $($memoryResult[0])/$($memoryResult[1])"
$totalScore += $memoryResult[0]
$maxScore += $memoryResult[1]
# Check event logs
$eventLogsResult = Check-EventLogs
$eventLogsScore = "Event Logs Score: $($eventLogsResult[0])/$($eventLogsResult[1])"
$totalScore += $eventLogsResult[0]
$maxScore += $eventLogsResult[1]
# Check Configuration Manager
$configMgrResult = Check-ConfigMgr
$configMgrScore = "Configuration Manager Score: $($configMgrResult[0])/$($configMgrResult[1])"
$totalScore += $configMgrResult[0]
$maxScore += $configMgrResult[1]
# Check pending reboots
$rebootResult = Check-PendingReboot
$rebootScore = "Pending Reboot Score: $($rebootResult[0])/$($rebootResult[1])"
$totalScore += $rebootResult[0]
$maxScore += $rebootResult[1]
# Calculate overall health score
$healthPercentage = ($totalScore / $maxScore) * 100
$overallScore = "Overall Health Score: $([math]::round($healthPercentage, 2))%"
# Create detailed HTML report
$reportPath = "$env:TEMP\HealthReport.html"
$htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Windows Health Report</title>
<style>
       body { font-family: Arial, sans-serif; margin: 40px; }
       h1 { color: #4CAF50; }
       table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
       th, td { padding: 12px; border: 1px solid #ddd; text-align: left; }
       th { background-color: #f2f2f2; }
       tr:nth-child(even) { background-color: #f9f9f9; }
</style>
</head>
<body>
<h1>Windows Health Report</h1>
<table>
<tr><th>Check</th><th>Score</th></tr>
<tr><td><a href="file:///C:/Users/179944/OneDrive%20-%20CHOA/scripts/working%20directory/ClientHealth.html#:~:text=Section%201%3A%20CPU%20Utilization">CPU Utilization</a></td><td>$($cpuResult[0])/$($cpuResult[1])</td></tr>
<tr><td>Memory Utilization</td><td>$($memoryResult[0])/$($memoryResult[1])</td></tr>
<tr><td>Disk Space</td><td>$($diskResult[0])/$($diskResult[1])</td></tr>
<tr><td>Pending Reboot</td><td>$($rebootResult[0])/$($rebootResult[1])</td></tr>
<tr><td>Configuration Manager</td><td>$($configMgrResult[0])/$($configMgrResult[1])</td></tr>
<tr><td>Service Running</td><td>$serviceScoresRunning/$($servicesToCheckRunning.Count)</td></tr>
<tr><td>Service Not Disabled</td><td>$serviceScoresNotDisabled/$($servicesToCheckNotDisabled.Count)</td></tr>
<tr><td>Event Logs</td><td>$($eventLogsResult[0])/$($eventLogsResult[1])</td></tr>
<tr><th>Overall Health Score</th><th>$([math]::round($healthPercentage, 2))%</th></tr>
</table>
</body>
</html>
"@
# Save the HTML content to a file
Set-Content -Path $reportPath -Value $htmlContent
# Display toast notification with the health status
$toastMessage = "Click to view detailed report."
New-BurntToastNotification -Text "Windows Health Status", $overallScore, $toastMessage -AppLogo $reportPath -Button @(
   New-BTButton -Content "View Report" -Arguments $reportPath
)