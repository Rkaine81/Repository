<#
Updates to make:
    1. Add concurrent jobs
    2. Retry each step that fails 3 times before exiting.


/#>
# Define file paths and list of computers
$computersListPath = "C:\CHOA\ComputersList.txt"
$filesToCopy = "\\CHOA-CIFS\install\CM_P01\06_InProduction\SoftwareDistribution\Microsoft\MECMClient.zip"
$destinationPath = "C$\CHOA"
$logFilePath = "C:\CHOA\SCCMFix_$(get-date -Format MMddyyyy).log"
$unzipTestPath = "C$\CHOA\MECMClient\ccmsetup.exe"
$processName = "ccmsetup"
$timeOutMinutes = 20

# SCCM client install and uninstall commands
$uninstallPath = "C:\Windows\ccmsetup\ccmsetup.exe"
$installPath = "C:\CHOA\MECMClient\ccmsetup.exe"
$installParams =  "SMSSITECODE=P01 SMSCACHESIZE=20480 SMSMP=DCVWP-SCCMAP01.choa.org FSP=DCVWP-SCCMAP01.choa.org CCMHTTPPORT=8080 CCMHTTPSPORT=443 RESETKEYINFORMATION=TRUE"
$unzipCommand = 'Expand-Archive -Path "C:\CHOA\MECMClient.zip" -DestinationPath "C:\CHOA\" -Force'


# Initialize log file
"Start of SCCM Client Operations Log" | Out-File -FilePath $logFilePath -Append

# Read the list of computers
$computers = Get-Content -Path $computersListPath

foreach ($computer in $computers) {
    try {

        # Check remote computer is accessible
        $var = Test-Connection -ComputerName $computer -Count 1 -ErrorAction SilentlyContinue

        if ($null -ne $var) {
            Write-Host "Test connection to $($computer) successful."
            "[$(Get-Date)] - $($computer): Connection test Succeeded.  Beginning repair." | Out-File -FilePath $logFilePath -Append
        }else{
            Write-Error "Test connection to $($computer) failed."
            "[$(Get-Date)] - $($computer): ERROR: Connection test failed." | Out-File -FilePath $logFilePath -Append
            Continue
        }

        # Copy files to the remote computer
        Write-Host "Copying files to $computer..."
        If (!(Test-Path "\\$computer\$destinationPath\MECMClient.zip")) {
            Copy-Item -Path $filesToCopy -Destination "\\$computer\$destinationPath" -Recurse -Force
        }

        # Verify file copy
        $filesCopied = Test-Path -Path "\\$computer\$destinationPath"
        if ($filesCopied) {
            "[$(Get-Date)] - $($computer): Files copied successfully." | Out-File -FilePath $logFilePath -Append
        } else {
            "[$(Get-Date)] - $($computer): ERROR: File copy failed." | Out-File -FilePath $logFilePath -Append
            Continue
        }

        # Unzip MECM Client Files
        Write-Host "Unzipping files to C:\CHOA\MECMClient on $computer..."
        If (!(Test-Path "\\$computer\$unzipTestPath")) {
            Invoke-Command -ComputerName $computer -ScriptBlock {
                param($unzipCmd)
                Invoke-Expression $unzipCmd
            } -ArgumentList $unzipCommand
        }

        start-sleep 3
        # Verify SCCM client unzipped
        $unzipped = Test-Path -Path "\\$computer\$unzipTestPath"
        start-sleep 3
        if ($unzipped) {
            "[$(Get-Date)] - $($computer) : SCCM client unzipped successfully." | Out-File -FilePath $logFilePath -Append
        } else {
            "[$(Get-Date)] - $($computer): ERROR: SCCM client unzipped failed." | Out-File -FilePath $logFilePath -Append
            Continue
        }

        # Uninstall SCCM client
        $x = $true
        $y = $true
        Write-Host "Uninstalling SCCM client on $computer..."

        If (get-service CCMExec -ComputerName $computer -ErrorAction SilentlyContinue) {
            Invoke-Command -ComputerName $computer -ScriptBlock {
                param($exePath)
                Start-Process -FilePath $exePath -ArgumentList '/uninstall' -Wait
            } -ArgumentList $uninstallPath

            write-host "Completed uninstall.  Beginning check."
            Start-Sleep -Seconds 5

            # Wait for uninstall to complete
            while ($x -eq $true) {
                try {
                    # Use Invoke-Command to check the process on the remote computer
                    $processExists = Invoke-Command -ComputerName $computer -ScriptBlock {
                        param($processName)
                        # Get the processes matching the specified process name
                        $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
                        # Return true if the process is found, otherwise false
                        return $process -ne $null
                    } -ArgumentList $processName

                    # Output the result
                    if ($processExists) {                    
                        Write-Output "Process '$processName' is running on $computer."
                    
                    } else {
                        Write-Output "Process '$processName' is not running on $computer."  
                        $x = $false                
                    }

                } catch {
                    Write-Output "Failed to check process on $($computer): $_"
                }

                # Wait for 5 seconds before the next check
                Start-Sleep -Seconds 5
            }
        
            Start-Sleep -Seconds 5

            write-host "Begin verification by checking remote service."
            # Verify SCCM client uninstallation
            $uninstalled = Invoke-Command -ComputerName $computer -ScriptBlock {
                # Check if the SCCM service is stopped and not present
                $service = Get-Service -Name 'CcmExec' -ErrorAction SilentlyContinue
                return ($null -eq $service)
            }

            if ($uninstalled) {
                "[$(Get-Date)] - $($computer) : SCCM client uninstalled successfully." | Out-File -FilePath $logFilePath -Append
            } else {
                "[$(Get-Date)] - $($computer): Error: SCCM client uninstallation failed." | Out-File -FilePath $logFilePath -Append
                Continue 
            }

            Start-Sleep -Seconds 5
        }else{
            Write-Host "The SCCM Client was not installed.  The uninstall was skipped."
            "[$(Get-Date)] - $($computer) : SCCM client was not installed." | Out-File -FilePath $logFilePath -Append
        }

        Start-Sleep -Seconds 5

        # Reinstall SCCM client
        Write-Host "Reinstalling SCCM client on $computer..."
        $startTime = Get-Date
        Invoke-Command -ComputerName $computer -ScriptBlock {
            param($exePath)
            Start-Process -FilePath $exePath -ArgumentList 'SMSSITECODE=P01 SMSCACHESIZE=20480 SMSMP=DCVWP-SCCMAP01.choa.org FSP=DCVWP-SCCMAP01.choa.org CCMHTTPPORT=8080 CCMHTTPSPORT=443 RESETKEYINFORMATION=TRUE' -Wait
        } -ArgumentList $installPath

        write-host "Completed install.  Beginning check."
        Start-Sleep -Seconds 5

        # Wait for install to complete
        while ($y -eq $true) {
            try {
                # Use Invoke-Command to check the process on the remote computer
                $processExists = Invoke-Command -ComputerName $computer -ScriptBlock {
                    param($processName)
                    # Get the processes matching the specified process name
                    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
                    # Return true if the process is found, otherwise false
                    return $process -ne $null
                } -ArgumentList $processName

                # Output the result
                if ($processExists) {
                    Write-Output "Process '$processName' is running on $computer."
                } else {
                    Write-Output "Process '$processName' is not running on $computer."
                    $y = $false
                }

                # Check timeout
                $elapsed = (Get-Date) - $startTime
                if ($elapsed.TotalMinutes -gt $timeOutMinutes) {
                    Write-Warning "Timeout reached installing SCCM after $timeoutMinutes minutes. Exiting loop for $computer."
                    Break
                }
            } catch {
                Write-Output "ERROR: Failed to check process on $($computer): $_"
            }

            # Wait for 5 seconds before the next check
            Start-Sleep -Seconds 5
        }

        Start-Sleep -Seconds 5

        write-host "Begin verification by checking remote service."
        # Verify SCCM client installation
        $installed = Invoke-Command -ComputerName $computer -ScriptBlock {
            # Check if the SCCM service is running
            $service = Get-Service -Name 'CcmExec' -ErrorAction SilentlyContinue
            return ($service -ne $null -and $service.Status -eq 'Running')
        }

        # Do a better check
        Write-Host "Verification returned: $($installed)." 

        if ($installed) {
            "[$(Get-Date)] - $($computer): SCCM client reinstalled and running successfully." | Out-File -FilePath $logFilePath -Append
        } else {
            "[$(Get-Date)] - $($computer): ERROR: SCCM client installation or initiation failed." | Out-File -FilePath $logFilePath -Append
        }
        

        # File Cleanup
        Write-Host "Removing installation files."
        if (Test-Path "\\$computer\$destinationPath\MECMClient.zip") {remove-item "\\$computer\$destinationPath\MECMClient.zip" -Force}
        if (Test-Path "\\$computer\$destinationPath\MECMClient") {remove-item "\\$computer\$destinationPath\MECMClient" -Force -Recurse}

        If (!(Test-Path "\\$computer\$destinationPath\MECMClient") -and (!(Test-Path "\\$computer\$destinationPath\MECMClient.zip"))) {
            "[$(Get-Date)] - $($computer) : SCCM installation files have been deleted." | Out-File -FilePath $logFilePath -Append
        }else{
            "[$(Get-Date)] - $($computer) : WARNING! SCCM installation files could not be deleted." | Out-File -FilePath $logFilePath -Append
        }

        Write-Host "Operations completed on $computer."
    }
    catch {
        # Log error message
        "[$(Get-Date)] - $($computer): An error occurred - $_" | Out-File -FilePath $logFilePath -Append
    }
}

# Indicate end of log
"End of SCCM Client Operations Log" | Out-File -FilePath $logFilePath -Append 