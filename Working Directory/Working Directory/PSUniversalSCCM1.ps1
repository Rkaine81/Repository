
$SiteCode = "P01" 
$ProviderMachineName = "DCVWP-SCCMAP01.choa.org" 
$initParams = @{}
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams | Out-Null
}

Set-Location "$($SiteCode):\" @initParams


$Name = "SL4042683514857"

$cmObj = Get-CMDevice -Name $Name

$result = [PSCustomObject]@{
        DeviceName = $cmObj.name
        DeviceID = $cmObj.ResourceID
        User = $cmObj.username
}



Set-Location -Path 'C:'

Remove-PSDrive -Name 'P01' -Force -ErrorAction 'SilentlyContinue' > $null

return $result