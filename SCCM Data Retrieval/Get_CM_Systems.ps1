# Site configuration
$SiteCodeCAS = "CAS" # Site code 
$ProviderMachineNameCAS = "AOAAPWP00375.tfayd.com" # SMS Provider machine name
# Site configuration
$SiteCodeEC1 = "EC1" # Site code 
$ProviderMachineNameEC1 = "aoaapwp00227.tfayd.com" # SMS Provider machine name
# Site configuration
$SiteCodeEC2 = "EC2" # Site code 
$ProviderMachineNameEC2 = "ASHAPWP00180.tfayd.com" # SMS Provider machine name
# Site configuration
$SiteCodeIN1 = "IN1" # Site code 
$ProviderMachineNameIN1 = "ukromifwp203.tfayd.com" # SMS Provider machine name
# Site configuration
$SiteCodeWC1 = "WC1" # Site code 
$ProviderMachineNameWC1 = "USHAPWP00520.tfayd.com" # SMS Provider machine name
# Site configuration
$SiteCodeWC2 = "WC2" # Site code 
$ProviderMachineNameWC2 = "USHAPWP00882.tfayd.com" # SMS Provider machine name

# Customizations
$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors


# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCodeCAS -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCodeCAS -PSProvider CMSite -Root $ProviderMachineNameCAS @initParams
}

# Connect to the CAS drive if it is not already present
if((Get-PSDrive -Name $SiteCodeCAS -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCodeCAS -PSProvider CMSite -Root $ProviderMachineNameCAS @initParams
}

# Connect to the EC1 drive if it is not already present
if((Get-PSDrive -Name $SiteCodeEC1 -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCodeEC1 -PSProvider CMSite -Root $ProviderMachineNameEC1 @initParams
}

# Connect to the EC2 drive if it is not already present
if((Get-PSDrive -Name $SiteCodeEC2 -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCodeEC2 -PSProvider CMSite -Root $ProviderMachineNameEC2 @initParams
}

# Connect to the IN1 drive if it is not already present
if((Get-PSDrive -Name $SiteCodeIN1 -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCodeIN1 -PSProvider CMSite -Root $ProviderMachineNameIN1 @initParams
}

# Connect to the WC1 drive if it is not already present
if((Get-PSDrive -Name $SiteCodeWC1 -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCodeWC1 -PSProvider CMSite -Root $ProviderMachineNameWC1 @initParams
}

# Connect to the WC2 drive if it is not already present
if((Get-PSDrive -Name $SiteCodeWC2 -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCodeWC2 -PSProvider CMSite -Root $ProviderMachineNameWC2 @initParams
}

$SITELIST = "$SiteCodeCAS",
"$SiteCodeEC1",
"$SiteCodeEC2",
"$SiteCodeIN1",
"$SiteCodeWC1",
"$SiteCodeWC2"


foreach ($SITE in $SITELIST) {

    Set-Location "$($SITE):\" @initParams

    $SITESERVERS = (Get-CMSiteSystemServer).NetworkOSPath.trimstart("\\")

    foreach ($SITESERVER in $SITESERVERS) {
        Write-Output "$SITESERVER" | Out-File C:\temp\filename.txt -Append -Force -NoClobber


    }

}

