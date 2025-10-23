<#
Script Name: UninstallSoftware.ps1
Script Version: 1.0
Author: Adam Eaddy
Contributers: 
Date Created: 09/08/2023
Date Updated: 
Description: The purpose of this script is to silently uninstall software based on the uninstall string provided in the registry.  This script will set a custom logging path. 
             If that path is unavailable, the script will log to C:\Windows\Temp.  All details are logged.  This script will check the registry Uninstall key for an MSIExec 
             uninstall or for a Silent Uninstall string.  If either are found, it will attempt to run that string.  If there is a running process, we can identify that and choose 
             to have the script kill the process prior to the uninstall, or you can have the script exit. 
Changes:


Custom Exit Codes:
2: The software is currently running. Cannot uninstall.
3: The MSI Product code failed to convert to a GUID.
4: Could not set registry key.
5: No silent uninstall string found.
6: Failed to create log file & failed to write Registry key.
7: The MSI Product code failed to convert to a GUID & failed to write Registry key. 
8: No silent uninstall string found & failed to write Registry key. 
9: A registry entry that matches the software title could not be found.
10: Failed to create log file.
11: A registry entry that matches the software title could not be found & failed to write Registry key. (Success)
12: MSIExec uninstall failed. 
13: MSIExec uninstall failed & failed to write Registry key.
14: MSIExec uninstall successful & failed to write Registry key. (Success) 
15: Silent uninstall failed. 
16: Silent uninstall failed & failed to write Registry key.
17: Silent uninstall successful & failed to write Registry key. (Success) 
18: Uninstall completed, but uninstall registry key is still present.
19: Uninstall completed, but uninstall registry key is still present & failed to write Registry key.
20: Failed to stop running process.
21: Failed to stop running process & failed to write Registry key.
/#>



$SoftwareName = "cisco jabber"
    # This should be the name of the application as displayed in the registry via the Uninstall\Display Name key value. 
$processName = "ciscojabber"
    # This should be the name of the process as listed in Task Manager.
    # If this field is left blank, it will ignore the process check. 
$killProcess = $false    # ($true / $false)
    # $true - the script will kill the process if it finds it running.
    # $false - The script will not kill the process, and will exit if it is running. 
$vLogPath = "C:\USGDAT"
    # Set this path to any path you would like.
    # Is this path cannot be created, the log file will be stored in C:\Windows\Temp
$vLogFileName = "$SoftwareName-Uninstall.log"
    # This will be the name of the output log file. .
$msiLogFile = "$vLogPath\$SoftwareName-Uninstall-MSI.log"
    # This will be the name of the MSI uninstall log. 
$remRegKeyPath = "HKLM:\SOFTWARE\WOW6432Node\NBCU\Uninstall"
    # Set this to the path you want the registry value stored in.
$remRegKeyProperty = "$SoftwareName state"
    # Set this to the key property name.
$remRegKeyType = "STRING"
    # Set this to the reg key type
    # Options: "DWORD" / "STRING"
$remRegPropertyValue = "Removing"
    # This value will begin as "Removing".  As the script runs, this value will change to "Failed", "Not Found", or "Successful".



    #########################################
    # DO NOT CHANGE CONTENT BELOW THIS LINE #
    #########################################

    ### Begin Functions ###

# Function: Get-RegUninstallKey
# Gets the uninstall string for a a software title from the Uninstall registry key.
# Example: (Get-RegUninstallKey -DisplayName $SoftwareName).uninstallstring
function Get-RegUninstallKey{
	param (
		[string]$DisplayName
	)
	$ErrorActionPreference = 'Continue'
	$uninstallKeys = "registry::HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall", "registry::HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
	$softwareTable = @()
	
	foreach ($key in $uninstallKeys)
	{
		$softwareTable += Get-Childitem $key | 
		Get-ItemProperty | 
		Where-Object {$_.displayname} | Sort-Object -Property displayname
	}
	if ($DisplayName)
	{
		$softwareTable | Where-Object {$_.displayname -Like "*$DisplayName*"}
	}
	else
	{
		$softwareTable | Sort-Object -Property displayname -Unique
	}
	
}

# Function: Set-logPath
# Set logging directory and file to custom defined directory, or the system temp directory as fallback dir.
# Example: Set-LogPath -logFileName "Test.log" -logPath "C:\Temp"
Function Set-rLogPath {

        Param(
            [Parameter(Mandatory=$true)]
            [string]$rlogFileName,
            [Parameter(Mandatory=$true)]
            [string]$rlogPath
        )
    
        # Test to see if custom log directory exist
        If(!(test-path -PathType container $rlogPath)) {
            # Create custom log directory if not exist
            New-Item -ItemType Directory -Path $rlogPath -ErrorAction SilentlyContinue | Out-Null
            # Verify the log directory was created
            If(!(test-path $rlogPath)) {
                # If directory not found, set new log dir path to the system temp directory
                $rlogPath = $env:TEMP
                # Test to see if log file already exists in the temp dir.  If not, create file.
                If(!(test-path "$rlogPath\$rlogFileName")) { New-Item -ItemType File -Path $rlogPath -Name $rlogFileName | Out-Null }
                # Test to validate log file was created in the temp dir
                If(!(test-path "$rlogPath\$rlogFileName")) {
                    # If log file not found in the temp dir, output to StdOut that log file could not be created.  Return False
                    Write-Output "A Log file could not be created in $rlogPath."
                    return $false
                }else{
                    # If the log file was created in the temp dir, set variable for full log path and write path to StdOut
                    $logFile = "$rlogPath\$rlogFileName"
                    Write-Output "$logFile"
                }
            }else{
                # If custom logging directory IS found, test to see if log file exists, if not, create log file.
                If(!(test-path "$rlogPath\$rlogFileName")) { New-Item -ItemType File -Path $rlogPath -Name $rlogFileName | Out-Null }
                # Test to validate log file was created in custom log dir. 
                If(!(test-path "$rlogPath\$rlogFileName")) {
                    # If log file not created in custom log dir, set new log dir path to the temp dir.
                    $rlogPath = $env:TEMP
                    # Test to see if log file already exists in the temp dir.  If not, create file.
                    If(!(test-path "$rlogPath\$rlogFileName")) { New-Item -ItemType File -Path $rlogPath -Name $rlogFileName | Out-Null }
                    # Test to validate log file was created in the temp dir.
                    If(!(test-path "$rlogPath\$rlogFileName")) {
                        # If log file not found in the temp dir, output to StdOut that log file could not be created.  Return False
                        Write-Output "A Log file could not be created in $rlogPath."
                        return $false
                    }else{
                        # If the log file was created in the temp dir, set variable for full log path and write path to StdOut
                        $logFile = "$rlogPath\$rlogFileName"
                        Write-Output "$logFile"
                    }
                }else{
                    # The log file was crerated in custom log dir. 
                    $logFile = "$rlogPath\$rlogFileName"
                    Write-Output "$logFile"
                }
            }
        }else{
            # The custom log direcotry already exists.  Check for log file, and create if not exist.      
            If(!(test-path "$rlogPath\$rlogFileName")) { New-Item -ItemType File -Path $rlogPath -Name $rlogFileName | Out-Null }
            # Test to verify the log file was created in the custom log directory.
            If(!(test-path "$rlogPath\$rlogFileName")) {
                # If not created, set new log path to the temp dir.
                $rlogPath = $env:TEMP
                # Test to see if log file already exists in the temp dir.  If not, create file.
                If(!(test-path "$rlogPath\$rlogFileName")) { New-Item -ItemType File -Path $rlogPath -Name $rlogFileName | Out-Null }
                # Test to validate log file was created
                If(!(test-path "$rlogPath\$rlogFileName")) {
                    # If log file not found, output to StdOut that log file could not be created.  Return False
                    Write-Output "A Log file could not be created in $rlogPath."
                    return $false
                }else{
                    # If the log file was created, set variable for full log path and write path to StdOut
                    $logFile = "$rlogPath\$rlogFileName"
                    Write-Output "$logFile"
                }
            }else{
                # The log file exists in custom log dir.  Set log path and output full path to StdOut
                $logFile = "$rlogPath\$rlogFileName"
                Write-Output "$logFile"
            }
        }
    }

# Function Write-RegKey
# Create registry key if it doesn't exist. Modify entry value. 
# Example: Write-RegKey "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" "DWord" "1"

function Write-RegKey {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][string]$registryPath,
        [Parameter(Mandatory=$true)][string]$regName,
        [Parameter(Mandatory=$true)][string]$regType,
        [Parameter(Mandatory=$true)][string]$regValue
    )
    Write-output "Checking if registry key $registryPath\$regName exists..."
    $keyExists = (Test-Path -Path $registryPath) -and (Get-ItemProperty -Path $registryPath -Name $regName)
    if ($keyExists) {
        Write-output "Registry key $registryPath\$regName exists, setting value to $regValue"
        Set-ItemProperty -Path $registryPath -Name $regName -Value $regValue -Type $regType
    } else {
        Write-output "Registry key $registryPath\$regName does not exist, creating with value $regValue"
        try {
            New-Item -Path $registryPath -Force
            New-ItemProperty -Path $registryPath -Name $regName -Value $regValue -Type $regType
        } catch {
            Write-Log "Failed to create registry key $registryPath\$regName : $_"
        }
    }
}

# Logging Function
# Write to the log file with formatting already applied.
# Example: Write-Log "This is a log entry." $rlogPath
Function Write-Log {

    param(
        [Parameter(Mandatory=$true)]
        [string]$VALUE,
        [Parameter(Mandatory=$true)]
        [string]$FULLLOGPATH
    )

    write-output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] $VALUE" | out-file $FULLLOGPATH -Append -Force -NoClobber

}

    ### End Functions ###

# Get Device Name
$deviceName = $env:COMPUTERNAME

# Begin Log File Creation
$rlogFile = Set-rLogPath -rlogFileName $vLogFileName -rlogPath $vLogPath -ErrorAction SilentlyContinue
# Verify that Log file was created
if ($rlogFile -eq $false) {
    Write-Output "The log file could not be created.  The script will exit."
    Write-RegKey -registryPath $remRegKeyPath -regName $remRegKeyProperty -regType $remRegKeyType -regValue $remRegPropertyValue
    # Verify Reg key value is set properly
    if (((Get-ItemProperty -Path $remRegKeyPath -Name $remRegKeyProperty -ErrorAction SilentlyContinue).$remRegKeyProperty) -ne $remRegPropertyValue) {
        Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Error: The Registry key ($remRegKeyProperty) value ""$remRegPropertyValue"" at $remRegKeyPath, could not be verified."
        Exit 6
    }
    Exit 10
}

# Begin Logging
Write-Log "### Being uninstall process for $SoftwareName on $deviceName ###" $rlogFile
Write-Log "Device Name : $deviceName" $rlogFile 
Write-Log "Software Title : $SoftwareName" $rlogFile


# Create Uninstall Reg Key
Write-Log "Setting Uninstall Registry key ($remRegKeyProperty) at $remRegKeyPath to ""$remRegPropertyValue""." $rlogFile
Write-RegKey -registryPath $remRegKeyPath -regName $remRegKeyProperty -regType $remRegKeyType -regValue $remRegPropertyValue
# Verify Reg key value is set properly
if (((Get-ItemProperty -Path $remRegKeyPath -Name $remRegKeyProperty -ErrorAction SilentlyContinue).$remRegKeyProperty) -ne $remRegPropertyValue) {
    Write-Log "Error: The Uninstall Registry key ($remRegKeyProperty) value ""$remRegPropertyValue"" at $remRegKeyPath, could not be verified." $rlogFile
    Exit 4
}else{
    Write-Log "Successfully set Uninstall reg key to $remRegPropertyValue" $rlogFile
}


Write-Log "Getting uninstall string from registry." $rlogFile
$UnInstallString = (Get-RegUninstallKey -DisplayName $SoftwareName).uninstallstring
If (-not $UnInstallString){
    Write-Log "Could not find registry key matching the software title." $rlogFile
    #Set registry key to Not Found.
    $remRegPropertyValue = "Not Found"
    Write-Log "Setting Uninstall Registry key ($remRegKeyProperty) at $remRegKeyPath to ""$remRegPropertyValue""." $rlogFile
    Write-RegKey -registryPath $remRegKeyPath -regName $remRegKeyProperty -regType $remRegKeyType -regValue $remRegPropertyValue
    # Verify Reg key value is set properly
    if (((Get-ItemProperty -Path $remRegKeyPath -Name $remRegKeyProperty -ErrorAction SilentlyContinue).$remRegKeyProperty) -ne $remRegPropertyValue) {
        Write-Log "Error: The Uninstall Registry key ($remRegKeyProperty) value ""$remRegPropertyValue"" at $remRegKeyPath, could not be verified." $rlogFile
        Exit 11
    }else{
        Write-Log "Successfully set Uninstall reg key to $remRegPropertyValue" $rlogFile
    }
    Exit 9
}


If ($killProcess -eq $false) {

    Write-Log "Checking running processes for: $processName" $rlogFile
    $processRuning = Get-Process -Name $processName -ErrorAction SilentlyContinue

    if (!($null -eq $processRuning)){
        Write-Log "*** The process $processName is currently running. Cannot uninstall the software: $SoftwareName.  Exiting script. ***" $rlogFile
        Write-Log "If this script was deployed using SCCM, the uninstall will attempt to run again." $rlogFile
        #Set registry key to failed
        $remRegPropertyValue = "Failed"
        Write-Log "Setting Uninstall Registry key ($remRegKeyProperty) at $remRegKeyPath to ""$remRegPropertyValue""." $rlogFile
        Write-RegKey -registryPath $remRegKeyPath -regName $remRegKeyProperty -regType $remRegKeyType -regValue $remRegPropertyValue
        # Verify Reg key value is set properly
        if (((Get-ItemProperty -Path $remRegKeyPath -Name $remRegKeyProperty -ErrorAction SilentlyContinue).$remRegKeyProperty) -ne $remRegPropertyValue) {
            Write-Log "Error: The Uninstall Registry key ($remRegKeyProperty) value ""$remRegPropertyValue"" at $remRegKeyPath, could not be verified." $rlogFile
            Exit 4
        }else{
            Write-Log "Successfully set Uninstall reg key to $remRegPropertyValue" $rlogFile
        }
        exit 2

    }
}
If ($killProcess -eq $true) {

    Write-Log "Checking running processes for: $processName" $rlogFile
    $processRuning = Get-Process -Name $processName -ErrorAction SilentlyContinue

    if (!($null -eq $processRuning)){
        Write-Log "The process $processName is currently running. Attempting to kill process." $rlogFile
        
        Try {
            Write-Log "Stopping process..." $rlogFile
            $ErrorActionPreference = 'Stop'
            Stop-Process -InputObject $processRuning -Force
            Start-Sleep -Seconds 5
            $processRuningValidation = Get-Process -Name $processName -ErrorAction SilentlyContinue
            if (-not $processRuningValidation) {
                Write-Log "The process has been successfully stopped." $rlogFile
            }else{
                Write-Log "The process $processName Could not be stopped.  Exiting the script." $rlogFile
                $ErrorMessage = $_.Exception.Message
                Write-Log "Error Details: $ErrorMessage; Description: $_;" $rlogFile
                #Set registry key to failed
                $remRegPropertyValue = "Failed"
                Write-Log "Setting Uninstall Registry key ($remRegKeyProperty) at $remRegKeyPath to ""$remRegPropertyValue""." $rlogFile
                Write-RegKey -registryPath $remRegKeyPath -regName $remRegKeyProperty -regType $remRegKeyType -regValue $remRegPropertyValue
                # Verify Reg key value is set properly
                if (((Get-ItemProperty -Path $remRegKeyPath -Name $remRegKeyProperty -ErrorAction SilentlyContinue).$remRegKeyProperty) -ne $remRegPropertyValue) {
                    Write-Log "Error: The Uninstall Registry key ($remRegKeyProperty) value ""$remRegPropertyValue"" at $remRegKeyPath, could not be verified." $rlogFile
                    Exit 21
                }else{
                    Write-Log "Successfully set Uninstall reg key to $remRegPropertyValue" $rlogFile
                }
                Exit 20
            }
        }
        Catch {
            Write-Log "The process $processName Could not be stopped.  Exiting the script." $rlogFile
            $ErrorMessage = $_.Exception.Message
            Write-Log "Error Details: $ErrorMessage; Description: $_;" $rlogFile
            #Set registry key to failed
            $remRegPropertyValue = "Failed"
            Write-Log "Setting Uninstall Registry key ($remRegKeyProperty) at $remRegKeyPath to ""$remRegPropertyValue""." $rlogFile
            Write-RegKey -registryPath $remRegKeyPath -regName $remRegKeyProperty -regType $remRegKeyType -regValue $remRegPropertyValue
            # Verify Reg key value is set properly
            if (((Get-ItemProperty -Path $remRegKeyPath -Name $remRegKeyProperty -ErrorAction SilentlyContinue).$remRegKeyProperty) -ne $remRegPropertyValue) {
                Write-Log "Error: The Uninstall Registry key ($remRegKeyProperty) value ""$remRegPropertyValue"" at $remRegKeyPath, could not be verified." $rlogFile
                Exit 21
            }else{
                Write-Log "Successfully set Uninstall reg key to $remRegPropertyValue" $rlogFile
            }
            Exit 20
        }
    }
}

Write-Log "Uninstall String: $UnInstallString" $rlogFile
Write-Log "Verifying the uninstall string is using MSIExec for silent uninstall." $rlogFile
# Test if Uninstall string is using MSIExec
if ($UnInstallString -match 'msiexec'){
    # Find the MSI Product code by getting the uninstall string and doing some simple string manipulation
    write-log "The uninstaller is using MSIExec." $rlogFile
    $MsiProductCode = ((($UnInstallString) -split '{') -split '}')[1]
    Write-Log "MSI Product Code: $MsiProductCode" $rlogFile

    # Test the MSIProduct code by type casting to GUID. This will throw a terminating error if incorrect
    try {
        [GUID]$MsiProductCode 
    }
    Catch {
        # Catch the error and output to file
        $_ | Out-File $rlogFile -ErrorAction SilentlyContinue -Append -NoClobber -Force
        # Output the registry key to the same log file for thoroughness 
        Get-RegUninstallKey -displayname $SoftwareName | Out-File $rlogFile -Append -NoClobber -Force -ErrorAction SilentlyContinue
        #Set registry key to failed
        $remRegPropertyValue = "Failed"
        Write-Log "Setting Uninstall Registry key ($remRegKeyProperty) at $remRegKeyPath to ""$remRegPropertyValue""." $rlogFile
        Write-RegKey -registryPath $remRegKeyPath -regName $remRegKeyProperty -regType $remRegKeyType -regValue $remRegPropertyValue
        # Verify Reg key value is set properly
        if (((Get-ItemProperty -Path $remRegKeyPath -Name $remRegKeyProperty -ErrorAction SilentlyContinue).$remRegKeyProperty) -ne $remRegPropertyValue) {
            Write-Log "Error: The Uninstall Registry key ($remRegKeyProperty) value ""$remRegPropertyValue"" at $remRegKeyPath, could not be verified." $rlogFile
            Exit 7
        }else{
            Write-Log "Successfully set Uninstall reg key to $remRegPropertyValue" $rlogFile
        }
        Exit 3
    } 
    # Run Uninstall command with logging
    Write-Log "The uninstall string is: msiexec /x ""{$MsiProductCode}"" /qn /norestart /l*v $rlogFile" $rlogFile
    Write-Log "Beginning the uninstall:" $rlogFile
    Write-Log "* Begin MSI Logging *" $rlogFile
    Write-Log "You can see the MSI log file here: $msiLogFile." $rlogFile

    Try {
        $ErrorActionPreference = 'Stop'
        #msiexec /x "{$MsiProductCode}" /qn /norestart /l*v $rlogFile
        #start-process msiexec.exe -ArgumentList "/x {$MsiProductCode} /qn /norestart /l*v $rlogFile"
        $productCode = $UnInstallString.Substring(14)
        Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList "/x $productCode /qn /norestart /l*v ""$msiLogFile""" -Wait
        Write-Log "* End MSI Logging *" $rlogFile
        Write-Log "Uninstall process complete. Validating software is removed." $rlogFile
        #Validating Uninstall regkey is no longer present.
        $validateUninstall = Get-RegUninstallKey -DisplayName $SoftwareName
        If (-not $validateUninstall) {
            #Set registry key to Successful
            $remRegPropertyValue = "Successful"
            Write-Log "Setting Uninstall Registry key ($remRegKeyProperty) at $remRegKeyPath to ""$remRegPropertyValue""." $rlogFile
            Write-RegKey -registryPath $remRegKeyPath -regName $remRegKeyProperty -regType $remRegKeyType -regValue $remRegPropertyValue
            # Verify Reg key value is set properly
            if (((Get-ItemProperty -Path $remRegKeyPath -Name $remRegKeyProperty -ErrorAction SilentlyContinue).$remRegKeyProperty) -ne $remRegPropertyValue) {
                Write-Log "Error: The Uninstall Registry key ($remRegKeyProperty) value ""$remRegPropertyValue"" at $remRegKeyPath, could not be verified." $rlogFile
                Exit 14
            }else{
                Write-Log "Successfully set Uninstall reg key to $remRegPropertyValue" $rlogFile
            }
        }else{
            Write-Log "The uninstall ran, but the uninstall registry key is still present. Exiting script." $rlogFile
             #Set registry key to Failed
            $remRegPropertyValue = "Failed"
            Write-Log "Setting Uninstall Registry key ($remRegKeyProperty) at $remRegKeyPath to ""$remRegPropertyValue""." $rlogFile
            Write-RegKey -registryPath $remRegKeyPath -regName $remRegKeyProperty -regType $remRegKeyType -regValue $remRegPropertyValue
            # Verify Reg key value is set properly
            if (((Get-ItemProperty -Path $remRegKeyPath -Name $remRegKeyProperty -ErrorAction SilentlyContinue).$remRegKeyProperty) -ne $remRegPropertyValue) {
                Write-Log "Error: The Uninstall Registry key ($remRegKeyProperty) value ""$remRegPropertyValue"" at $remRegKeyPath, could not be verified." $rlogFile
                Exit 19
            }else{
                Write-Log "Successfully set Uninstall reg key to $remRegPropertyValue" $rlogFile
            }
            Exit 18
        }
        Exit 0
    }
    Catch {
        $ErrorMessage = $_.Exception.Message
        Write-Log "FAILURE : MSIExec uninstall failed for $deviceName and resulted in an error." $rlogFile
        Write-Log "Error Details: $ErrorMessage; Description: $_;" $rlogFile
        # Update Reg Key
        $remRegPropertyValue = "Failed"
        Write-Log "Updating Uninstall Registry key ($remRegKeyProperty) at $remRegKeyPath to ""$remRegPropertyValue""." $rlogFile
        Write-RegKey -registryPath $remRegKeyPath -regName $remRegKeyProperty -regType $remRegKeyType -regValue $remRegPropertyValue
        # Verify Reg key value is set properly
        if (((Get-ItemProperty -Path $remRegKeyPath -Name $remRegKeyProperty -ErrorAction SilentlyContinue).$remRegKeyProperty) -ne $remRegPropertyValue) {
            Write-Log "Error: The Remediant Registry key ($remRegKeyProperty) value ""$remRegPropertyValue"" at $remRegKeyPath, could not be verified." $rlogFile
            Exit 13
        }
        exit 12
    }
}else{
    # Uninstall string does not contain MSIExec, try quietuninstall string
    Write-Log "The uninstall string does not contain MSIExec.  Trying ""quietuninstall"" string" $rlogFile
    $QuietUninstallString = (Get-RegUninstallKey -DisplayName $SoftwareName).QuietUninstallString
    if (-Not $QuietUninstallString){
        # If quiet uninstall string is not found in reg key, log to file, then quit script
        Write-Log "No silent uninstall string was found." $rlogFile
        Get-RegUninstallKey -displayname $SoftwareName #| $logFile -Append -ErrorAction SilentlyContinue
            #Set registry key to failed
        $remRegPropertyValue = "Failed"
        Write-Log "Setting Uninstall Registry key ($remRegKeyProperty) at $remRegKeyPath to ""$remRegPropertyValue""." $rlogFile
        Write-RegKey -registryPath $remRegKeyPath -regName $remRegKeyProperty -regType $remRegKeyType -regValue $remRegPropertyValue
        # Verify Reg key value is set properly
        if (((Get-ItemProperty -Path $remRegKeyPath -Name $remRegKeyProperty -ErrorAction SilentlyContinue).$remRegKeyProperty) -ne $remRegPropertyValue) {
            Write-Log "Error: The Uninstall Registry key ($remRegKeyProperty) value ""$remRegPropertyValue"" at $remRegKeyPath, could not be verified." $rlogFile
            Exit 8
        }else{
            Write-Log "Successfully set Uninstall reg key to $remRegPropertyValue" $rlogFile
        }
        Exit 5
    }
    # Execute QuietUninstallString
    Write-Log "The silent uninstall string is: $QuietUninstallString" $rlogFile
    Write-Log "Beginning the uninstall:" $rlogFile
    Try {
        $ErrorActionPreference = 'Stop'
        $QUS = $QuietUninstallString.Split('"')
        $iPath = $QUS[1]
        $iParams = $QUS[2]
        #& cmd /c $QuietUninstallString
        start-process $iPath -ArgumentList $iParams -Wait
        Write-Log "Uninstall process complete. Validating software is removed." $rlogFile
        #Validating Uninstall regkey is no longer present.
        $validateUninstall = Get-RegUninstallKey -DisplayName $SoftwareName
        If (-not $validateUninstall) {
            #Set registry key to Successful
            $remRegPropertyValue = "Successful"
            Write-Log "Setting Uninstall Registry key ($remRegKeyProperty) at $remRegKeyPath to ""$remRegPropertyValue""." $rlogFile
            Write-RegKey -registryPath $remRegKeyPath -regName $remRegKeyProperty -regType $remRegKeyType -regValue $remRegPropertyValue
            # Verify Reg key value is set properly
            if (((Get-ItemProperty -Path $remRegKeyPath -Name $remRegKeyProperty -ErrorAction SilentlyContinue).$remRegKeyProperty) -ne $remRegPropertyValue) {
                Write-Log "Error: The Uninstall Registry key ($remRegKeyProperty) value ""$remRegPropertyValue"" at $remRegKeyPath, could not be verified." $rlogFile
                Exit 17
            }else{
                Write-Log "Successfully set Uninstall reg key to $remRegPropertyValue" $rlogFile
            }
        }
    }
    Catch {
        $ErrorMessage = $_.Exception.Message
        Write-Log "FAILURE : Silent uninstall failed for $deviceName and resulted in an error." $rlogFile
        Write-Log "Error Details: $ErrorMessage; Description: $_;" $rlogFile
        # Update Reg Key
        $remRegPropertyValue = "Failed"
        Write-Log "Updating Uninstall Registry key ($remRegKeyProperty) at $remRegKeyPath to ""$remRegPropertyValue""." $rlogFile
        Write-RegKey -registryPath $remRegKeyPath -regName $remRegKeyProperty -regType $remRegKeyType -regValue $remRegPropertyValue
        # Verify Reg key value is set properly
        if (((Get-ItemProperty -Path $remRegKeyPath -Name $remRegKeyProperty -ErrorAction SilentlyContinue).$remRegKeyProperty) -ne $remRegPropertyValue) {
            Write-Log "Error: The Remediant Registry key ($remRegKeyProperty) value ""$remRegPropertyValue"" at $remRegKeyPath, could not be verified." $rlogFile
            Exit 16
        }
        exit 15
    }




        
}