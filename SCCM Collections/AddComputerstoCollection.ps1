#
# Press 'F5' to run this script. Running this script will load the ConfigurationManager
# module for Windows PowerShell and will connect to the site.
#
# This script was auto-generated at '4/28/2021 2:20:58 PM'.

# Uncomment the line below if running in an environment where script signing is 
# required.
#Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Site configuration
$SiteCode = "CAS" # Site code 
$ProviderMachineName = "AOAAPWP00375.TFAYD.COM" # SMS Provider machine name

# Customizations
$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

# Do not change anything below this line

# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams


$Computers = "N308DRH0N2",
"GDE-JLOLSEW0D",
"WTELAB-1909V",
"N30206649447SP",
"N30WM-1909VM10",
"JECG1B2X33",
"N30WM2-VM10",
"DESKTOP-QC75I9L",
"DESKTOP-8579RK1",
"NUUUNIITDOCHA7L",
"NUUUNIWDETEST",
"NUUUNITNGWI10D",
"GDE-VM10-JCT",
"NUFMIA9CMB7D3",
"NUUUNIDKFB7D3",
"DESKTOP-RUM2A4H"

$Collection = Get-CMDeviceCollection -Id "CAS02082"

foreach ($Computer in $Computers) {
    $CMDevice = Get-CMDevice -Name $Computer
    Add-CMDeviceCollectionDirectMembershipRule -InputObject $Collection -Resource $CMDevice
}