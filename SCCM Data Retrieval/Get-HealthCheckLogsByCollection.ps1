$collectionNames = "COMPLIANCE - Health Script Scheduled Task Present_Patch Non Compliant Devices via Qualys - No AMBH_Compliant"

$output = "C:\choa"
$logPath = "\\choa-cifs\install\WindowsLogs\ClientHealth"

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

    $devices = (Get-CMCollectionMember -CollectionName $collectionName).Name
    foreach ($device in $devices) {
        If (Test-Path $("filesystem::$logPath\$device.log")) {
            Copy-Item $("filesystem::$logPath\$device.log") "C:\CHOA\New Folder" -Force
        }
    }

}