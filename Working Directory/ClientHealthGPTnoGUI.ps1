# Function to check if a service is not disabled
function get-Service-NotDisabled {
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
 function get-Service-Running {
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
 function get-DiskSpace {
    $threshold = 20 # 20% free space threshold
    #$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match "^[a-zA-Z]:" }
    $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -eq "C:\" }
    $diskStatus = ""
    $score = 0
    foreach ($drive in $drives) {
        $driveTotal = ($drive.Free + $drive.Used)
        $freeSpacePercent = ($drive.Used / $driveTotal) * 100
        if ($freeSpacePercent -gt $threshold) {
            $diskStatus += "$($drive.Name): Healthy ($([math]::round($freeSpacePercent, 2))% free)`n"
            $score += 1
        } else {
            $diskStatus += "$($drive.Name): Low Disk Space ($([math]::round($freeSpacePercent, 2))% free)`n"
        }
    }
    $maxScore = $drives.Count
    return @($diskStatus, $score, $maxScore)
 }
 # Function to check CPU utilization
 function get-CPUUtilization {
    $cpu = Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -Average | Select-Object -ExpandProperty Average
    $utilizationStatus = "CPU Utilization: $cpu%`n"
    $score = 0
    if ($cpu -lt 80) {
        $utilizationStatus += "CPU Utilization: Healthy"
        $score = 1
    } else {
        $utilizationStatus += "CPU Utilization: High"
    }
    $maxScore = 1
    return @($utilizationStatus, $score, $maxScore)
 }
 # Function to check memory utilization
 function get-MemoryUtilization {
    $memory = Get-WmiObject win32_operatingsystem
    $freeMemory = $memory.FreePhysicalMemory
    $totalMemory = $memory.TotalVisibleMemorySize
    $usedMemoryPercent = (($totalMemory - $freeMemory) / $totalMemory) * 100
    $utilizationStatus = "Memory Utilization: $([math]::round($usedMemoryPercent, 2))%`n"
    $score = 0
    if ($usedMemoryPercent -lt 80) {
        $utilizationStatus += "Memory Utilization: Healthy"
        $score = 1
    } else {
        $utilizationStatus += "Memory Utilization: High"
    }
    $maxScore = 1
    return @($utilizationStatus, $score, $maxScore)
 }
 # Function to check for application crashes and other errors in event logs
 function get-EventLogs {
    $last24Hours = (Get-Date).AddHours(-24)
    $appErrors = Get-EventLog -LogName Application -After $last24Hours | Where-Object { $_.EntryType -eq "Error" }
    $sysErrors = Get-EventLog -LogName System -After $last24Hours | Where-Object { $_.EntryType -eq "Error" }
    $appCrashCount = $appErrors.Count
    $sysErrorCount = $sysErrors.Count
    $totalErrors = $appCrashCount + $sysErrorCount
    $errorStatus = "Application Errors: $appCrashCount in the last 24 hours`n"
    $errorStatus += "System Errors: $sysErrorCount in the last 24 hours`n"
    if ($totalErrors -eq 0) {
        $errorStatus += "Event Logs: Healthy"
        $score = 1
    } else {
        $errorStatus += "Event Logs: Issues Detected`n"
        #$errorStatus += "`nDetailed Errors:`n"
        foreach ($error in $appErrors) {
            #$errorStatus += "Application Error - Time: $($error.TimeWritten), Source: $($error.Source), Event ID: $($error.EventID), Message: $($error.Message)`n"
        }
        foreach ($error in $sysErrors) {
            #$errorStatus += "System Error - Time: $($error.TimeWritten), Source: $($error.Source), Event ID: $($error.EventID), Message: $($error.Message)`n"
        }
        $score = 0
    }
    $maxScore = 1
    return @($errorStatus, $score, $maxScore)
 }
 # Function to check Configuration Manager
 function get-ConfigMgr {
    $configMgrStatus = "Configuration Manager Status:`n"
    $configMgrServiceStatus = get-Service-NotDisabled -serviceName "CcmExec"
    $score = $configMgrServiceStatus
    if ($configMgrServiceStatus -eq 1) {
        $configMgrStatus += "CcmExec: Not Disabled`n"
    } else {
        $configMgrStatus += "CcmExec: Disabled`n"
    }
    $maxScore = 1
    return @($configMgrStatus, $score, $maxScore)
 }
 # Function to check for pending reboots
 function get-PendingReboot {
    $rebootRequired = $null -ne (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired' -ErrorAction SilentlyContinue)
    $score = $rebootRequired ? 0 : 1
    $result = $rebootRequired ? "Pending Reboot: Yes" : "Pending Reboot: No"
    $maxScore = 1
    return @($result, $score, $maxScore)
 }

 function Save-HealthScoresToJson {
    param (
        [int]$CPUsScore,
        [int]$MemoryScore,
        [int]$DiskScore,
        [int]$RebootScore,
        [int]$CfgmgrScore,
        [int]$ServiceRScore,
        [int]$ServiceDScore,
        [int]$EventsScore,
        [int]$OverallScore,
        [string]$JsonFilePath = "$env:TEMP\health_scores.json"
    )
    # Create the object to store the data
    $healthScores = [PSCustomObject]@{
        CPUScore      = $CPUsScore
        MemoryScore   = $MemoryScore
        DiskScore     = $DiskScore
        RebootScore   = $RebootScore
        CfgmgrScore   = $CfgmgrScore
        ServiceRScore = $ServiceRScore
        ServiceDScore = $ServiceDScore
        EventsScore   = $EventsScore
        OverallScore = $OverallScore
    }
    # Convert the object to JSON and save it to the specified file path
    $healthScores | ConvertTo-Json -Depth 3 | Set-Content -Path $JsonFilePath
 }

 # Main script
 $healthStatus = ""
 $totalScore = 0
 $maxScore = 0
 # Check if key services are not disabled
 $servicesToCheckNotDisabled = @("wuauserv", "BITS", "WinDefend", "CcmExec")
 $serviceScoresNotDisabled = 0
 foreach ($service in $servicesToCheckNotDisabled) {
    $serviceStatus = get-Service-NotDisabled -serviceName $service
    $healthStatus += "$service : " + ($serviceStatus -eq 1 ? "Not Disabled" : "Disabled") + "`n"
    $serviceScoresNotDisabled += $serviceStatus
    $totalScore += $serviceStatus
    $maxScore += 1
 }
 $healthStatus += "Service Not Disabled Check Score: $serviceScoresNotDisabled/$($servicesToCheckNotDisabled.Count)`n"
 # Check if key services are running
 $servicesToCheckRunning = @("BrokerInfrastructure", "CryptSvc", "DcomLaunch", "wlidsvc", "swprv", "RpcEptMapper", "WinRM")
 $serviceScoresRunning = 0
 foreach ($service in $servicesToCheckRunning) {
    $serviceStatus = get-Service-Running -serviceName $service
    $healthStatus += "$service : " + ($serviceStatus -eq 1 ? "Running" : "Not Running") + "`n"
    $serviceScoresRunning += $serviceStatus
    $totalScore += $serviceStatus
    $maxScore += 1
 }
 $healthStatus += "Service Running Check Score: $serviceScoresRunning/$($servicesToCheckRunning.Count)`n"
 # Check disk space
 $diskResult = get-DiskSpace
 $healthStatus += "`nDisk Space Status:`n" + $diskResult[0] + "`n"
 $healthStatus += "Disk Space Score: $($diskResult[1])/$($diskResult[2])`n"
 $totalScore += $diskResult[1]
 $maxScore += $diskResult[2]
 # Check CPU utilization
 $cpuResult = get-CPUUtilization
 $healthStatus += "`nCPU Utilization:`n" + $cpuResult[0] + "`n"
 $healthStatus += "CPU Utilization Score: $($cpuResult[1])/$($cpuResult[2])`n"
 $totalScore += $cpuResult[1]
 $maxScore += $cpuResult[2]
 # Check memory utilization
 $memoryResult = get-MemoryUtilization
 $healthStatus += "`nMemory Utilization:`n" + $memoryResult[0] + "`n"
 $healthStatus += "Memory Utilization Score: $($memoryResult[1])/$($memoryResult[2])`n"
 $totalScore += $memoryResult[1]
 $maxScore += $memoryResult[2]
 # Check event logs
 $eventLogsResult = get-EventLogs
 $healthStatus += "`nEvent Logs:`n" + $eventLogsResult[0] + "`n"
 $healthStatus += "Event Logs Score: $($eventLogsResult[1])/$($eventLogsResult[2])`n"
 $totalScore += $eventLogsResult[1]
 $maxScore += $eventLogsResult[2]
 # Check Configuration Manager
 $configMgrResult = get-ConfigMgr
 $healthStatus += "`n" + $configMgrResult[0] + "`n"
 $healthStatus += "Configuration Manager Score: $($configMgrResult[1])/$($configMgrResult[2])`n"
 $totalScore += $configMgrResult[1]
 $maxScore += $configMgrResult[2]
 # Check pending reboots
 $rebootResult = get-PendingReboot
 $healthStatus += "`n" + $rebootResult[0] + "`n"
 $healthStatus += "Pending Reboot Score: $($rebootResult[1])/$($rebootResult[2])`n"
 $totalScore += $rebootResult[1]
 $maxScore += $rebootResult[2]
 # Calculate overall health score
 $healthPercentage = ($totalScore / $maxScore) * 100
 $healthStatus += "`nOverall Health Score: $([math]::round($healthPercentage, 2))%"
 # Output the health status to the console
Write-Output $healthStatus

 # Example usage
 Save-HealthScoresToJson -CPUsScore 90 -MemoryScore 85 -DiskScore 80 -RebootScore 70 -CfgmgrScore 95 -ServiceRScore 75 -ServiceDScore 80 -EventsScore 65
 