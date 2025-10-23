# Set the path to your text file and the string you want to match

$logFilePath = "\\choa-cifs\install\WindowsLogs\ClientHealth"
$files = Get-ChildItem -Path $logFilePath

$searchString00 = "Hostname:"
$searchString01 = "Repaired"
$searchString02 = "Missing or faulty driver"
$searchString03 = "ClientInstalledReason:"
$searchString04 = "Restarted"
$searchString05 = "PendingReboot:"
$searchString06 = "OSUpdates:"
$searchString07 = "DNS:"
$searchString08 = "LastBootTime:"
$searchString09 = "OSDiskFreeSpace:"
$searchString10 = "Services:"
$searchString11 = "AdminShare:"
$searchString12 = "StateMessages:"
$searchString13 = "WUAHandler:"
$searchString14 = "WMI:"

# Use Select-String to search for the string and return the matching lines

foreach ($file in $files) {

    $filepath = $file.FullName

    $hostname = Select-String -Path $filePath -Pattern $searchString00 | ForEach-Object { $_.Line } 
    $repaired = Select-String -Path $filePath -Pattern $searchString01 | ForEach-Object { $_.Line } 
    $drivers = Select-String -Path $filePath -Pattern $searchString02 | ForEach-Object { $_.Line } 
    $clientInstall = Select-String -Path $filePath -Pattern $searchString03 | ForEach-Object { $_.Line } 
    $restartedServices = Select-String -Path $filePath -Pattern $searchString04 | ForEach-Object { $_.Line }
    $pendingReboots = Select-String -Path $filePath -Pattern $searchString05 | ForEach-Object { $_.Line }
    $updates = Select-String -Path $filePath -Pattern $searchString06 | ForEach-Object { $_.Line }
    $dns = Select-String -Path $filePath -Pattern $searchString07 | ForEach-Object { $_.Line }
    $lastBoot = Select-String -Path $filePath -Pattern $searchString08 | ForEach-Object { $_.Line }
    $freeSpace = Select-String -Path $filePath -Pattern $searchString09 | ForEach-Object { $_.Line }
    $services = Select-String -Path $filePath -Pattern $searchString10 | ForEach-Object { $_.Line }
    $adminShare = Select-String -Path $filePath -Pattern $searchString11 | ForEach-Object { $_.Line }
    $stateMessages = Select-String -Path $filePath -Pattern $searchString12 | ForEach-Object { $_.Line }
    $wua = Select-String -Path $filePath -Pattern $searchString13 | ForEach-Object { $_.Line }
    $wmi = Select-String -Path $filePath -Pattern $searchString14 | ForEach-Object { $_.Line }



#Hostname & Run Count
    if ($hostname.count -gt 1) {$newHostName = $hostname[0]} else {$newHostName = $hostname}
    $newhostname = $newHostName.TrimStart("Hostname: ")
    #Write-Output $newHostName
    #Write-Output "Run Count: $($hostname.count)"
    
#Pending Reboots
    if ($pendingReboots.count -eq 1) {
        if ($pendingReboots -eq "PendingReboot: OK"){
            #Write-Output "Pending Reboot: No"
            $rebootOutput = "No"
        }else{
            #Write-Output "Pending Reboot: Yes"
            $rebootOutput = "Yes"
        }
    }else{
        if ($pendingReboots[-1] -eq "PendingReboot: OK") {
            #Write-Output "Pending Reboot: No"
            $rebootOutput = "No"
        }else{
            #Write-Output "Pending Reboot: Yes"
            $rebootOutput = "Yes"
        }
        $x=0
        foreach ($pendingReboot in $pendingReboots) {
            if ($pendingReboot -ne "PendingReboot: OK"){
                $x = $x + 1
            }
        }
        #Write-Output "Reboot Count: $x"
        $rebootCount = $x
    }

#Drivers
    If ($null -eq $drivers) {$driverErrorResults = "0"}

    if ($drivers.count -ge 1) {
        if ($drivers.count -eq 1) {
            #Write-Output "Driver Error Count: $($drivers.count)"
            $driverErrorResults = $drivers.count
            $pos1 = $drivers.IndexOf("]LOG]")
            $drivers = $drivers.Substring(0, $pos1)
            $pos2 = $drivers.IndexOf("Missing")
            $driverOutput = $drivers.Substring($pos2)
            #$drivers.Substring($pos2)
        }
        if ($drivers.count -gt 1) {
            [System.Collections.ArrayList]$dArray = @()
            foreach ($driver in $drivers) {
                $pos1 = $driver.IndexOf("]LOG]")
                $driver = $driver.Substring(0, $pos1)
                $pos2 = $driver.IndexOf("Missing")
                #$driver.Substring($pos2)
                $dArray += $driver.Substring($pos2) 
            }
            $sArray = $dArray | select -Unique
            #Write-Output "Driver Error Count: $($sArray.count)"
            $driverErrorResults = $sArray.count
            #$sArray
            $driverString = $sArray -join "/"

        }
    }


#Repaired
    $repaired | select -Unique

#Services
    $restartedServices | select -Unique

#Client Install
    foreach ($CI in $clientInstall) {
        If ($CI -ne "ClientInstalledReason: ") {
            $CI
        }
    }


Write-Output "$newHostName, $($hostname.count), $rebootOutput, $rebootCount, $driverErrorResults"

#$(if ($drivers.count -eq 1){$driverOutput}), $(if ($drivers.count -gt 1){$driverString})

}