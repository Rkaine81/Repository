 <#
Script Version: 2.0
Author: Adam Eaddy (179944)
Date Created: 08/07/2024
Description: The purpose of this script is to disable TLS settings and to comply with ADV180012.
#>
 
################
#Begin Functions
################
 
 Function WriteRegKey{
 #Create registry path if it doesn't exist. Then modify entry value. 
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
    #Try{
        #Get-ItemProperty $registryPath
        If(!(Test-Path $registryPath)){
            New-Item -Path $registryPath -Force

        }
        New-ItemProperty -Path $registryPath -Name $regName -PropertyType $regType -Value $regValue -Force
    #}
    
    #Catch{AppendLog "$((Get-PSCallStack)[1].Command) Set Registry Value failed: $LASTEXITCODE; Error Details: $($_.ErrorDetails); Error Stack Trace: $($_.ScriptStackTrace); Target Object: $($_.TargetObject); Invocation Info: $($_.InvocationInfo)"}

}

function Test-RegistryKeyValue {
    <#
    .SYNOPSIS
    Tests if a registry value exists.

    .DESCRIPTION
    The usual ways for checking if a registry value exists don't handle when a value simply has an empty or null value.  This function actually checks if a key has a value with a given name.

    .EXAMPLE
    Test-RegistryKeyValue -Path 'hklm:\Software\Carbon\Test' -Name 'Title'

    Returns `True` if `hklm:\Software\Carbon\Test` contains a value named 'Title'.  `False` otherwise.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The path to the registry key where the value should be set.
        $Path,

        [Parameter(Mandatory=$true)]
        [string]
        # The name of the value being set.
        $Name
    )

    if( -not (Test-Path -Path $Path -PathType Container) )
    {
        return $false
    }

    $properties = Get-ItemProperty -Path $Path 
    if( -not $properties )
    {
        return $false
    }

    $member = Get-Member -InputObject $properties -Name $Name
    if( $member )
    {
        return $true
    }
    else
    {
        return $false
    }

}

Function Write-Log {

    param(
        [Parameter(Mandatory=$true)]
        [string]$VALUE
    )

    $SDATE = get-date -Format MMddyyyy
    $LOGPATH = "C:"
    #Set Log name
    $LOGFILE = "ADV180012_v2.log"
    $FULLLOGPATH = "$LOGPATH\$LOGFILE"

    write-output "$(get-date): $VALUE" | out-file $FULLLOGPATH -Append -Force -NoClobber

}

##############
#End Functions
##############

clear

Write-Host "Beginning the Mitigation for Transaction Asynchronous Abort vulnerability, Microarchitectural Data Sampling, Spectre, Meltdown, MMIO, Speculative Store Bypass Disable (SSBD), and L1 Terminal Fault (L1TF) with Hyper-Threading disabled on Intel Processors." -ForegroundColor Yellow
Write-Log "Beginning the Mitigation for Transaction Asynchronous Abort vulnerability, Microarchitectural Data Sampling, Spectre, Meltdown, MMIO, Speculative Store Bypass Disable (SSBD), and L1 Terminal Fault (L1TF) with Hyper-Threading disabled on Intel Processors."
Start-Sleep 2

$ErrorActionPreference = "SilentlyContinue"

#CfgItem Registry Value Exists
$regKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
$regValue = "FeatureSettingsOverrideMask"
$regValueProperty = "3"

WriteRegKey -registryPath "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" -regName "FeatureSettingsOverrideMask" -regType "Dword" -regValue $regValueProperty | out-null

if ((Test-RegistryKeyValue -Path $regKey -Name $regValue)) {

    if (((Get-ItemProperty -path $regKey).$regValue) -eq $regValueProperty) {
        Write-Host "Registry value added successfully.  Please manually validate using Registry Editor." -ForegroundColor Green
        Write-Host "Registry Key:  HKEY_LOCAL_MACHINE:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
        Write-Host "Registry Property:  FeatureSettingsOverrideMask"
        Write-Host "Registry Property:  3"
        Write-log "Registry value added successfully.  Please manually validate using Registry Editor."
        Write-log "Registry Key:  HKEY_LOCAL_MACHINE:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
        Write-log "Registry Property:  FeatureSettingsOverrideMask"
        Write-log "Registry Property:  3"

    }else{
        Write-Host "Registry value failed to add.  Please contact the IS&T team for assistance." -ForegroundColor Red
        Write-Log "Registry value failed to add.  Please contact the IS&T team for assistance."
    }
}else{
     Write-Host "Registry value failed to add.  Please contact the IS&T team for assistance." -ForegroundColor Red
     Write-Log "Registry value failed to add.  Please contact the IS&T team for assistance."
}



Write-Host "The script has completed.  You can find the log file at C:\ADV180012_v2.log."