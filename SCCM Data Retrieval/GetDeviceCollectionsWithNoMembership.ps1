#Script Name: GetDeviceCollectionsWithNoMembership.ps1
#Script Version: 1.0
#Author: Adam Eaddy
#Date Created: 03/11/2021
#Description: This script will list all of the CM Device Collections that have no membership rules associated to them..
#Changes:

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

# Do not change anything below this line

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

#Define Logging
$DATE = Get-Date
$SDATE = get-date -Format MMddyyyy
$LOGPATH = "C:\temp"
#Set Log name
$LOGFILE = "GetDeviceCollectionsWithNoMembership_$SDATE.log"
$FULLLOGPATH = "$LOGPATH\$LOGFILE"
$CSVFILE = "GetDeviceCollectionsWithNoMembership_$SDATE.csv"
$FULLCSVPATH = "$LOGPATH\$CSVFILE"

# Set the current location to be the site code.
Set-Location "$($SiteCodeCAS):\" @initParams

Write-Output "---Begin Listing Device Collections. - $DATE---" | Out-File $FULLLOGPATH -Append -Force -NoClobber
Write-Output "Collection Name,Include Rule Count,Include Rule Name,Exclude Rule Count,Exclude Rule Name,Direct Member Rule Count,Query Rule Count,Query Rule Name" | Out-File $FULLCSVPATH -Append -Force -NoClobber
Write-Output "Collection Name,Include Rule Count,Include Rule Name,Exclude Rule Count,Exclude Rule Name,Direct Member Rule Count,Query Rule Count,Query Rule Name" | Out-File $FULLLOGPATH -Append -Force -NoClobber

$COLLOBJS = Get-CMDeviceCollection

Foreach($COLLOBJ in $COLLOBJS) {


    $IMR = Get-CMDeviceCollectionIncludeMembershipRule -InputObject $COLLOBJ
    $EMR = Get-CMDeviceCollectionExcludeMembershipRule -InputObject $COLLOBJ
    $DMR = Get-CMDeviceCollectionDirectMembershipRule -InputObject $COLLOBJ
    $QMR = Get-CMDeviceCollectionQueryMembershipRule -InputObject $COLLOBJ

    $IMRC = $IMR.count
    $EMRC = $EMR.count
    $DMRC = $DMR.count
    $QMRC = $QMR.count

    $IMRN = $IMR.rulename
    $EMRN = $EMR.rulename
    $DMRN = $DMR.rulename
    $QMRN = $QMR.rulename

    Write-Output "$($COLLOBJ.Name),$IMRC,$IMRN,$EMRC,$EMRN,$DMRC,$QMRC,$QMRN"  | Out-File $FULLCSVPATH -Append -Force -NoClobber
    Write-Output "$($COLLOBJ.Name),$IMRC,$IMRN,$EMRC,$EMRN,$DMRC,$QMRC,$QMRN"  | Out-File $FULLLOGPATH -Append -Force -NoClobber

}

Write-Output "---Completed listing Device Collections. - $DATE---" | Out-File $FULLLOGPATH -Append -Force -NoClobber