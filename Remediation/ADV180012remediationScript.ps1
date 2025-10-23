 <#
Script Version: 1.0
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
    $LOGFILE = "ADV180012.log"
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
$regKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
$regValue = "FeatureSettingsOverride"
$regValueProperty = "0x00802048"

WriteRegKey -registryPath "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -regName "FeatureSettingsOverride" -regType "Dword" -regValue "0x00802048" | out-null

if ((Test-RegistryKeyValue -Path $regKey -Name $regValue)) {

    if (((Get-ItemProperty -path $regKey).$regValue) -eq $regValueProperty) {
        Write-Host "Registry value added successfully.  Please manually validate using Registry Editor." -ForegroundColor Green
        Write-Host "Registry Key:  HKEY_LOCAL_MACHINE:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
        Write-Host "Registry Property:  FeatureSettingsOverride"
        Write-Host "Registry Property:  0x00802048"
        Write-log "Registry value added successfully.  Please manually validate using Registry Editor."
        Write-log "Registry Key:  HKEY_LOCAL_MACHINE:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
        Write-log "Registry Property:  FeatureSettingsOverride"
        Write-log "Registry Property:  0x00802048"

    }else{
        Write-Host "Registry value failed to add.  Please contact the IS&T team for assistance." -ForegroundColor Red
        Write-Log "Registry value failed to add.  Please contact the IS&T team for assistance."
    }
}else{
     Write-Host "Registry value failed to add.  Please contact the IS&T team for assistance." -ForegroundColor Red
     Write-Log "Registry value failed to add.  Please contact the IS&T team for assistance."
}


Write-Host "Attempting to disable the TLS Cipher Suite." -ForegroundColor Yellow
Write-Log "Attempting to disable the TLS Cipher Suite."
Start-Sleep 2


If (!($null -eq (Get-TlsCipherSuite -Name "TLS_RSA_WITH_3DES_EDE_CBC_SHA"))) {
    Disable-TlsCipherSuite -Name "TLS_RSA_WITH_3DES_EDE_CBC_SHA"
}else{
    Write-Host "The TLS Cipher Suite is already disabled." -ForegroundColor Green
    Write-Log "The TLS Cipher Suite is already disabled."
}


If (!($null -eq (Get-TlsCipherSuite -Name "TLS_RSA_WITH_3DES_EDE_CBC_SHA"))) {
    Write-Host "The TLS Cipher Suite was successfully disabled." -ForegroundColor Green
    Write-Log "The TLS Cipher Suite was successfully disabled."
}else{
    Write-Host "Could not disbale TLS.  Verifying the TLS PowerShell module is installed." -ForegroundColor Yellow
    Write-Log "Could not disbale TLS.  Verifying the TLS PowerShell module is installed."

    if ($null -eq (get-module TLS)) {
        Write-Host "The TLS Cipher Suite could not be disabled.  Please contact the IS&T team for assistance." -ForegroundColor Red
        Write-Log "The TLS Cipher Suite could not be disabled.  Please contact the IS&T team for assistance."
    }else{
         Write-Host "The PowerShell module is installed Correctly.  Trying agian." -ForegroundColor Yellow
         Write-Log "The PowerShell module is installed Correctly.  Trying agian."
         Disable-TlsCipherSuite -Name "TLS_RSA_WITH_3DES_EDE_CBC_SHA"
         If ($null -eq (Get-TlsCipherSuite -Name "TLS_RSA_WITH_3DES_EDE_CBC_SHA")) {
            Write-Host "The TLS Cipher Suite was successfully disabled." -ForegroundColor Green
            Write-Log "The TLS Cipher Suite was successfully disabled."
         }else{
            Write-Host "The TLS Cipher Suite could not be disabled.  Please contact the IS&T team for assistance." -ForegroundColor Red
            Write-Log "The TLS Cipher Suite could not be disabled.  Please contact the IS&T team for assistance."
         }
    }
}

Write-Host "The script has completed.  You can find the log file at C:\ADV180012.log."