#Script Name: FederatedAddDirectCollectionMembersFromCSV.ps1
#Script Version: 1.0
#Author: Adam Eaddy
#Date Created: 03/15/2021
#Description: This script will import a list of devices from a CSV file and add the devices to a collection via a direct membership.
#Changes:

$FULLCSVPATH = "C:\TEMP\computers.txt"

# Site configuration
$SiteCodeCAS = "CAS" # Site code 
$ProviderMachineNameCAS = "AOAAPWP00375.tfayd.com" # SMS Provider machine name
$initParams = @{}
# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}
# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCodeCAS -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCodeCAS -PSProvider CMSite -Root $ProviderMachineNameCAS @initParams
}

#Define Logging
$DATE = Get-Date
$SDATE = get-date -Format MMddyyyy
$LOGPATH = "C:\TEMP\working"
#Set Log name
$LOGFILE = "AddDirectCollectionMembersFromCSV_$SDATE.log"
$FULLLOGPATH = "$LOGPATH\$LOGFILE"

write-output "Writing log to $FULLLOGPATH."

# Set the current location to be the site code.
Set-Location "$($SiteCodeCAS):\" @initParams

$COMPLIST = Import-Csv -Path $FULLCSVPATH -Header Collection,Computers

Write-Output "---Begin adding direct membership of devices. - $(get-date)---" | Out-File $FULLLOGPATH -Append -Force -NoClobber

$COLLNAME2 = $null

foreach ($COMP in $COMPLIST) {
    $COMPNAME = $Comp.Computers
    $COMPOBJ = Get-CMDevice -Name $COMPNAME
    $COLLNAME1 = $COMP.Collection
    
    if ($COLLNAME1 -ne $COLLNAME2) {
        $COLLECTION = Get-CMDeviceCollection -Name $COLLNAME1
        $COLLNAME2 = $COLLNAME1
    }

    Write-Output "---Adding direct membership of $COMPNAME to $COLLNAME1. - $(get-date)---" | Out-File $FULLLOGPATH -Append -Force -NoClobber
    Add-CMDeviceCollectionDirectMembershipRule -InputObject $COLLECTION -Resource $COMPOBJ | Out-File $FULLLOGPATH -Append -Force -NoClobber
}

Write-Output "---Completed adding direct membership of devices. - $(get-date)---" | Out-File $FULLLOGPATH -Append -Force -NoClobber


