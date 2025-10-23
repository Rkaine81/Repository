#Function to test registry value existance.
#Example: Test-RegistryValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" 
function Test-RegistryValue {

    param (

     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Key,

    [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Name
    )

    try {

        Get-ItemProperty -Path $Key -Name $Name -ErrorAction Stop | Out-Null
        return $true
    }

    catch {

    return $false

    }

}

$HostName = [System.Net.Dns]::GetHostName()

# Get the date/time that the system last booted up.
$LastBootUpTime = [System.DateTime]::Now - [System.TimeSpan]::FromMilliseconds([System.Environment]::TickCount)

# Determine if a Windows Vista/Server 2008 and above machine has a pending reboot from a Component Based Servicing (CBS) operation.
$IsCBServicingRebootPending = Test-Path -LiteralPath 'Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'

# Determine if there is a pending reboot from a Windows Update.
$IsWindowsUpdateRebootPending = Test-Path -LiteralPath 'Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'

# Determine if there is a pending reboot from an App-V global Pending Task. (User profile based tasks will complete on logoff/logon).
$IsAppVRebootPending = Test-Path -LiteralPath 'Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Software\Microsoft\AppV\Client\PendingTasks'

# Get the value of PendingFileRenameOperations.
$PendingFileRenameOperations = if ($IsFileRenameRebootPending = (Test-RegistryValue -Key 'Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager' -Name 'PendingFileRenameOperations'))
{
    try
    {
        Get-ItemProperty -LiteralPath 'Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager' | Select-Object -ExpandProperty PendingFileRenameOperations
    }
    catch
    {
        $failureMEssage =  "Failed to get PendingFileRenameOperations: $($_.Exception.Message)"
    }
}

# Determine SCCM 2012 Client reboot pending status.
$IsSCCMClientRebootPending = try
{
    if (($SCCMClientRebootStatus = Invoke-CimMethod -Namespace ROOT\CCM\ClientSDK -ClassName CCM_ClientUtilities -Name DetermineIfRebootPending).ReturnValue -eq 0)
    {
        $SCCMClientRebootStatus.IsHardRebootPending -or $SCCMClientRebootStatus.RebootPending
    }
}
catch
{
    Write-Output "Failed to get IsSCCMClientRebootPending."
}

# Create a custom object containing pending reboot information for the system.
$PendingRebootInfo = [PSCustomObject]@{
    ComputerName = $HostName
    LastBootUpTime = $LastBootUpTime
    IsSystemRebootPending = $IsCBServicingRebootPending -or $IsWindowsUpdateRebootPending -or $IsFileRenameRebootPending -or $IsSCCMClientRebootPending
    IsCBServicingRebootPending =  $IsCBServicingRebootPending
    IsWindowsUpdateRebootPending =  $IsWindowsUpdateRebootPending
    IsSCCMClientRebootPending = $IsSCCMClientRebootPending
    IsAppVRebootPending = $IsAppVRebootPending
    IsFileRenameRebootPending  = $IsFileRenameRebootPending
    PendingFileRenameOperations = $PendingFileRenameOperations
}


If ($PendingRebootInfo.IsSystemRebootPending) {
    return $true
}else{
    return $false
}


If ($PendingRebootInfo.IsWindowsUpdateRebootPending) {
    return $true
}else{
    return $false
}