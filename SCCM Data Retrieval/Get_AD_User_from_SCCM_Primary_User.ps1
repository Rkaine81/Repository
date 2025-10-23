#
# Press 'F5' to run this script. Running this script will load the ConfigurationManager
# module for Windows PowerShell and will connect to the site.
#
# This script was auto-generated at '3/25/2025 4:09:26 PM'.

# Site configuration
$SiteCode = "P01" # Site code 
$ProviderMachineName = "DCVWP-SCCMAP01.choa.org" # SMS Provider machine name

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

$ErrorActionPreference = "SilentlyContinue"

$CollMembers = Get-CMCollectionMember -CollectionId P0101DB4
foreach ($collMember in $CollMembers) {

    $devAff = Get-CMUserDeviceAffinity -DeviceName ($collMember).Name
    #Write-Output "$($devAff.ResourceName) & $($devAff.UniqueUserName)"
    $user = (($devAff).UniqueUserName)
    $user = ($user).ToLower()
    $user = ($user).TrimStart("choa\")
    $adUser = Get-ADUser -Identity $user -Properties Department | Select-Object Name, Department
    #Write-Output "$($adUser.Name),$($adUser.Department)"
    Write-Output "$($adUser.Name),$($adUser.Department),$($devAff.ResourceName)" | out-file C:\CHOA\ClassicOutlookPhishMeUsers_4-2-25_exclusions.csv -Force -Append -NoClobber

}

