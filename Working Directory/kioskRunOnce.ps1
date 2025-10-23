$SDATE = get-date -Format MMddyyyy
$LOGPATH = "C:\Windows\Logs"
#Set Log name
$LOGFILE = "kioskRunOnce_$SDATE.log"
$FULLLOGPATH = "$LOGPATH\$LOGFILE"
$compName = $env:COMPUTERNAME
$alUser = "user"+$compName
$alVar1=[string][char[]][int[]]("38.88.120.70.81.119.51.51.118.55.99.103".Split(".")) -replace " "


Function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VALUE
    )
    write-output "$(get-date): $VALUE" | out-file $FULLLOGPATH -Append -Force -NoClobber
}

#Create registry path if it doesn't exist. Modify entry value. 
#Example: Write-RegKey "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" "DWord" "1"
 Function Write-RegKey{
 
    Param(
        [Parameter(Mandatory=$true)]
        [string]$registryPath,
        [Parameter(Mandatory=$true)]
        [string]$regName,
        [Parameter(Mandatory=$true)]
        [string]$regType,
        [Parameter(Mandatory=$true)]
        [string]$regValue
    )
    

        
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Checking for the Registry key: $registryPath\$regName."
    If(!(Test-RegistryValue $registryPath $regName)){Write-Log "Attempting to write RegKey: $registryPath\$regName"}

    If(!(Test-Path $registryPath)){
        Write-Log "Attempting to write RegKey: $registryPath."
        New-Item -Path $registryPath -Force
            If(Test-Path $registryPath){Write-Log "RegKey: $registryPath exists."}else{Write-Log "Error: The reg key could not be created."}
    }

    $WRCHECK = $null
    if (((Get-ItemProperty -Path $registryPath -Name $regName).$regname) -ne $regValue) {
        Write-Log "The Registry Value data does not match the required data value.  Settings the data value to: $regValue"
        New-ItemProperty -Path $registryPath -Name $regName -PropertyType $regType -Value $regValue -Force | Write-Output
        $WRCHECK = "1"
    }else{
        Write-Log "The registry value is already set to $regValue."
    }


    if ($WRCHECK = "1"){
        if (((Get-ItemProperty -Path $registryPath -Name $regName).$regname) -eq $regValue) {
            Write-Log "The Registry Value data is set to: $regValue"
        }else{
            Write-Log "Error: The registry value data could not be set."
        }
    }
    
}


#Beginning Configuration
Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
Write-Log "Beginning Configuration of $env:COMPUTERNAME."
Write-Log "Beginning installation of Autologon.exe"
$ReturnFromEXE = Start-Process "C:\users\public\Autologon.exe" -ArgumentList "$alUser","CHOA",$alVar1,"/accepteula" -NoNewWindow -Wait -Passthru
Write-Log "App finished with exit code  $($ReturnFromEXE.ExitCode)"
Write-RegKey "HKLM:\SOFTWARE\Microsoft\Deployment 4" "KioskRunOnceComplete" "DWord" "1"
write-log "Restarting Windows"
Start-Sleep 10
Restart-Computer -Force
