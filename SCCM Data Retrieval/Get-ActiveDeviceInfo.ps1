$list = Import-Csv -Path "C:\Temp\Unscanned.csv" -Header devices

$SiteCode = "P01" # Site code 
$ProviderMachineName = "DCVWP-SCCMAP01.choa.org" # SMS Provider machine name

$initParams = @{}

if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams

$results = @()
Write-Output "Name, Client, IsActive, LastActive, DaysSinceLastCheckIn, LastPolicy, LastADLogTime, LastActive, PrimaryUser" | out-file C:\choa\deviceReport.csv -Append -Force
foreach ($item in $list) {
    $deviceInfo = Get-CMDevice -Name $item.devices
    # Gather all results into a single PSObject

    $days = ((Get-Date) - ($deviceInfo.LastActiveTime))

    $deviceObj = [PSCustomObject]@{
        Name = ($item.devices).ToUpper()
        Client = if ($null -eq $deviceInfo.IsClient) {"False"} else {$deviceInfo.IsClient}
        Active = if ($null -eq $deviceInfo.IsActive) {"False"} else {$deviceInfo.IsActive}
        DaysSinceLastCheckIn = $days.Days
        LastActive = if ($null -eq $deviceInfo.LastActiveTime) {"Not Checked In"} else {$deviceInfo.LastActiveTime}
        LastPolicy = if ($null -eq $deviceInfo.LastPolicyRequest) {"Not Checked In"} else {$deviceInfo.LastPolicyRequest}
        PrimaryUser = if ($null -eq $deviceInfo.PrimaryUser) {"N/A"} else {$deviceInfo.PrimaryUser}
        LastOnlineTime = if ($null -eq $deviceInfo.CNLastOnlineTime) {"Not Checked In"} else {$deviceInfo.CNLastOnlineTime}
        LastADLogTime = if ($null -eq $deviceInfo.ADLastLogonTime) {"Not Checked In"} else {$deviceInfo.ADLastLogonTime}
        
    }

    Write-Output "$($deviceObj.name), $($deviceObj.Client), $($deviceObj.Active), $($deviceObj.LastActive), $($deviceInfo.DaysSinceLastCheckIn), $($deviceObj.LastPolicy), $($deviceObj.LastADLogTime), $($deviceObj.LastOnlineTime), $($deviceObj.PrimaryUser)" | out-file C:\choa\deviceReport.csv -Append -Force
}


