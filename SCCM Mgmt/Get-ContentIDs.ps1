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
# Get all packages and applications
$packages = Get-CMPackage
$applications = Get-CMApplication
# Array to store content IDs
$contentData = @()
# Extract content IDs from packages
foreach ($pkg in $packages) {
   $contentData += [PSCustomObject]@{
       ContentID = $pkg.PackageID
       Type      = "Package"
       Name      = $pkg.Name
   }
}
# Extract content IDs from applications
foreach ($app in $applications) {
   $deploymentTypes = $app | Get-CMDeploymentType
   foreach ($dt in $deploymentTypes) {
       $contentData += [PSCustomObject]@{
           ContentID = $dt.ContentID
           Type      = "Application"
           Name      = $app.LocalizedDisplayName
       }
   }
}
# Export content IDs to a CSV file
$outputPath = "C:\CHOA\ContentIDs.csv"  # Replace with your desired output path
$contentData | Export-Csv -Path $outputPath -NoTypeInformation
Write-Host "Content IDs exported to $outputPath"