# Define file paths and list of computers
$computersListPath = "C:\CHOA\ComputersList.txt"
$filesToCopy = "\\CIFS\install\P01\06_InProduction\SoftwareDistribution\Microsoft\MECMClient.zip"
$destinationPath = "C$\CHOA"
$logFilePath = "C:\CHOA\SCCMFix_Conc_$(get-date -Format MMddyyyy).log"
$unzipTestPath = "C$\CHOA\MECMClient\ccmsetup.exe"
$processName = "ccmsetup"
$timeOutMinutes = 20

# SCCM client install and uninstall commands
$uninstallPath = "C:\Windows\ccmsetup\ccmsetup.exe"
$installPath = "C:\CHOA\MECMClient\ccmsetup.exe"
$installParams = "SMSSITECODE=P01 SMSCACHESIZE=20480 SMSMP=<server name> FSP=<server name> CCMHTTPPORT=8080 CCMHTTPSPORT=443 RESETKEYINFORMATION=TRUE"
$unzipCommand = 'Expand-Archive -Path "C:\CHOA\MECMClient.zip" -DestinationPath "C:\CHOA\" -Force'

# Initialize log file
"Start of SCCM Client Operations Log" | Out-File -FilePath $logFilePath -Append

# Read the list of computers
$computers = Get-Content -Path $computersListPath

# Define a maximum number of concurrent jobs
$maxConcurrentJobs = 5
$jobs = @()

foreach ($computer in $computers) {
    # Start a job for the current computer
    $job = Start-Job -ScriptBlock {
        param($computer, $filesToCopy, $destinationPath, $logFilePath, $unzipTestPath, $processName, $timeOutMinutes, $uninstallPath, $installPath, $installParams, $unzipCommand)

        # Define the retry mechanism inside the job
        function Invoke-WithRetry {
            param (
                [scriptblock]$ScriptBlock,
                [int]$Retries = 3,
                [int]$DelaySeconds = 5
            )

            for ($try = 1; $try -le $Retries; $try++) {
                try {
                    & $ScriptBlock
                    return $true
                } catch {
                    if ($try -eq $Retries) {
                        throw
                    }
                    Start-Sleep -Seconds $DelaySeconds
                }
            }
            return $false
        }

        try {
            # Check remote computer is accessible
            #"[$(Get-Date)] - $($computer): Beginning connection test." | Out-File -FilePath $logFilePath -Append
            if (-not (Invoke-WithRetry { Test-Connection -ComputerName $computer -Count 1 -ErrorAction Stop })) {
                "[$(Get-Date)] - $($computer): ERROR: Connection test failed." | Out-File -FilePath $logFilePath -Append
                return
            }
            "[$(Get-Date)] - $($computer): Connection test succeeded." | Out-File -FilePath $logFilePath -Append

            # Copy files to the remote computer
            If (Invoke-WithRetry { 
                If (!(Test-Path "\\$computer\$destinationPath\MECMClient.zip")) {
                    "[$(Get-Date)] - $($computer): Beginning file copy." | Out-File -FilePath $logFilePath -Append
                    Copy-Item -Path $filesToCopy -Destination "\\$computer\$destinationPath" -Recurse -Force -ErrorAction Stop
                }
            }) {
                "[$(Get-Date)] - $($computer): File copy succeeded." | Out-File -FilePath $logFilePath -Append
            } else {
                "[$(Get-Date)] - $($computer): ERROR: File copy failed." | Out-File -FilePath $logFilePath -Append
                return
            }

            # Unzip MECM Client Files
            If (Invoke-WithRetry {
                If (!(Test-Path "\\$computer\$unzipTestPath")) {
                    "[$(Get-Date)] - $($computer): Beginning ZIP extraction." | Out-File -FilePath $logFilePath -Append
                    Invoke-Command -ComputerName $computer -ScriptBlock {
                        param($unzipCmd)
                        Invoke-Expression $unzipCmd
                    } -ArgumentList $unzipCommand -ErrorAction Stop
                }
            }) {
                "[$(Get-Date)] - $($computer): SCCM client unzipped successfully." | Out-File -FilePath $logFilePath -Append
            } else {
                "[$(Get-Date)] - $($computer): ERROR: SCCM client unzip failed." | Out-File -FilePath $logFilePath -Append
                return
            }

            # Uninstall SCCM client
            If (Invoke-WithRetry {
                get-service CCMExec -ComputerName $computer -ErrorAction SilentlyContinue
            }) {
                If (Invoke-WithRetry {
                    "[$(Get-Date)] - $($computer): Beginning SCCM client uninstall." | Out-File -FilePath $logFilePath -Append
                    Invoke-Command -ComputerName $computer -ScriptBlock {
                        param($exePath)
                        Start-Process -FilePath $exePath -ArgumentList '/uninstall' -Wait -ErrorAction Stop
                    } -ArgumentList $uninstallPath
                }) {
                    "[$(Get-Date)] - $($computer): SCCM client uninstalled successfully." | Out-File -FilePath $logFilePath -Append
                } else {
                    "[$(Get-Date)] - $($computer): ERROR: SCCM client uninstallation failed." | Out-File -FilePath $logFilePath -Append
                    return
                }
            } else {
                "[$(Get-Date)] - $($computer): SCCM client was not installed, uninstallation skipped." | Out-File -FilePath $logFilePath -Append
            }

            # Reinstall SCCM client
            If (Invoke-WithRetry {
                "[$(Get-Date)] - $($computer): Beginning SCCM client install." | Out-File -FilePath $logFilePath -Append
                Invoke-Command -ComputerName $computer -ScriptBlock {
                    param($exePath, $installParams)
                    Start-Process -FilePath $exePath -ArgumentList $installParams -Wait -ErrorAction Stop
                } -ArgumentList $installPath, $installParams
            }) {
                # Wait for install to complete
                "[$(Get-Date)] - $($computer): Waiting for CCMSetup.exe to complete." | Out-File -FilePath $logFilePath -Append
                $y = $true
                $startTime = Get-Date
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
                        if (!($processExists)) {
                            $y = $false
                        }

                        # Check timeout
                        $elapsed = (Get-Date) - $startTime
                        if ($elapsed.TotalMinutes -gt $timeOutMinutes) {
                            "[$(Get-Date)] - $($computer): ERROR: Timeout reached installing SCCM after $timeoutMinutes minutes. Exiting loop for $computer." | Out-File -FilePath $logFilePath -Append
                            Break
                        }
                    } catch {
                        "[$(Get-Date)] - $($computer): ERROR: Can not validate CCMSetup.exe is running : $_" | Out-File -FilePath $logFilePath -Append
                    }

                    # Wait for 5 seconds before the next check
                    Start-Sleep -Seconds 5
                }

                "[$(Get-Date)] - $($computer): Verifying client installation." | Out-File -FilePath $logFilePath -Append
                # Verify SCCM client installation
                $installed = Invoke-Command -ComputerName $computer -ScriptBlock {
                    # Check if the SCCM service is running
                    $service = Get-Service -Name 'CcmExec' -ErrorAction SilentlyContinue
                    return ($service -ne $null -and $service.Status -eq 'Running')
                }

                if ($installed) {
                    "[$(Get-Date)] - $($computer): SCCM client reinstalled and running successfully." | Out-File -FilePath $logFilePath -Append
                } else {
                    "[$(Get-Date)] - $($computer): ERROR: SCCM client installation or initiation failed." | Out-File -FilePath $logFilePath -Append
                }
            } else {
                "[$(Get-Date)] - $($computer): ERROR: SCCM client installation failed." | Out-File -FilePath $logFilePath -Append
                return
            }

            # File Cleanup
            Invoke-WithRetry {
                "[$(Get-Date)] - $($computer): Beginning file cleanup." | Out-File -FilePath $logFilePath -Append
                if (Test-Path "\\$computer\$destinationPath\MECMClient.zip") { remove-item "\\$computer\$destinationPath\MECMClient.zip" -Force }
                if (Test-Path "\\$computer\$destinationPath\MECMClient") { remove-item "\\$computer\$destinationPath\MECMClient" -Force -Recurse }
            }
            "[$(Get-Date)] - $($computer): Installation files cleaned up successfully." | Out-File -FilePath $logFilePath -Append

            "[$(Get-Date)] - $($computer): Operations completed successfully." | Out-File -FilePath $logFilePath -Append
        }
        catch {
            "[$(Get-Date)] - $($computer): An error occurred - $_" | Out-File -FilePath $logFilePath -Append
        }
    } -ArgumentList $computer, $filesToCopy, $destinationPath, $logFilePath, $unzipTestPath, $processName, $timeOutMinutes, $uninstallPath, $installPath, $installParams, $unzipCommand

    $jobs += $job

    # Throttle the number of concurrent jobs
    while ($jobs.Count -ge $maxConcurrentJobs) {
        # Wait for any job to complete
        $completedJob = Wait-Job -Job $jobs -Any -Timeout 5
        if ($completedJob -ne $null) {
            # Remove completed job from the list
            $jobs = $jobs | Where-Object { $_.Id -ne $completedJob.Id }
            Receive-Job -Job $completedJob | Out-Null
            Remove-Job -Job $completedJob
        }
    }
}

# Wait for all remaining jobs to finish
$jobs | ForEach-Object { 
    Receive-Job -Job $_ -Wait | Out-Null
    Remove-Job -Job $_
}

# Indicate end of log
"End of SCCM Client Operations Log" | Out-File -FilePath $logFilePath -Append