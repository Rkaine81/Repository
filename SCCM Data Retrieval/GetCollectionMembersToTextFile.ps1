$collectionNames = "Satellite Sites"

$output = "C:\choa"

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

foreach ($collectionName in $collectionNames) {

(Get-CMCollectionMember -CollectionName $collectionName).Name | out-file "$output\$collectionName.txt" -Append -Force

}