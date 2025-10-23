
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


$collName = "Patch Mgmt Stage 0 - Test - Unit & AdHoc"

$cmObj = Get-CMDeviceCollection -Name $collName

$result = [PSCustomObject]@{
        Collection = $cmObj.name
        CollectionID = $cmObj.CollectionID
        Description = $cmObj.comment
}

return $result

Set-Location -Path 'C:'

Remove-PSDrive -Name 'P01' -Force -ErrorAction 'SilentlyContinue' > $null