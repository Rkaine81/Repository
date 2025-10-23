#Script Name: PILOTAddDirectCollectionMembersFromCSV.ps1
#Script Version: 1.0
#Author: Adam Eaddy
#Date Created: 03/12/2021
#Description: This script will import a list of devices from a DSV file and add the devices to a collection via a direct membership.
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
$LOGFILE = "PILOTAddDirectCollectionMembersFromCSV_$SDATE.log"
$FULLLOGPATH = "$LOGPATH\$LOGFILE"

# Set the current location to be the site code.
Set-Location "$($SiteCodeCAS):\" @initParams



Write-Output "---Begin adding direct membership of devices. - $DATE---" | Out-File $FULLLOGPATH -Append -Force -NoClobber


#1 - WTE Computers (Alert Only)
$COLLECTION1A = Get-CMDeviceCollection -Name "1 - WTE Computers (Alert Only)"
$COMPLIST1A = Import-Csv -Path "D:\Users\206676599\OneDrive - NBCUniversal\Scripts\script reference\working\1 - WTE Computers Alert Only.csv" -Header Collection,Computers

foreach ($COMP in $COMPLIST1A) {
    $COMPNAME = $Comp.Computers
    $COMPOBJ = Get-CMDevice -Name $COMPNAME
    Write-Output "---Adding direct membership of $COMP. - $DATE---" | Out-File $FULLLOGPATH -Append -Force -NoClobber
    Add-CMDeviceCollectionDirectMembershipRule -InputObject $COLLECTION1A -Resource $COMPOBJ | Out-File $FULLLOGPATH -Append -Force -NoClobber
}

#1 - WTE Computers
$COLLECTION1 = Get-CMDeviceCollection -Name "1 - WTE Computers"
$COMPLIST = Import-Csv -Path "D:\Users\206676599\OneDrive - NBCUniversal\Scripts\script reference\working\1 - WTE Computers.csv" -Header Collection,Computers

foreach ($COMP in $COMPLIST1) {
    $COMPNAME = $Comp.Computers
    $COMPOBJ = Get-CMDevice -Name $COMPNAME
    Write-Output "---Adding direct membership of $COMP. - $DATE---" | Out-File $FULLLOGPATH -Append -Force -NoClobber
    Add-CMDeviceCollectionDirectMembershipRule -InputObject $COLLECTION1 -Resource $COMPOBJ | Out-File $FULLLOGPATH -Append -Force -NoClobber
}

#2 - CS - All
$COLLECTION2 = Get-CMDeviceCollection -Name "2 - CS - All"
$COMPLIST2 = Import-Csv -Path "D:\Users\206676599\OneDrive - NBCUniversal\Scripts\script reference\working\2 - CS - All.csv" -Header Collection,Computers

foreach ($COMP in $COMPLIST2) {
    $COMPNAME = $Comp.Computers
    $COMPOBJ = Get-CMDevice -Name $COMPNAME
    Write-Output "---Adding direct membership of $COMP. - $DATE---" | Out-File $FULLLOGPATH -Append -Force -NoClobber
    Add-CMDeviceCollectionDirectMembershipRule -InputObject $COLLECTION2 -Resource $COMPOBJ | Out-File $FULLLOGPATH -Append -Force -NoClobber
}

#3 - Chris Kearns Org OLD
$COLLECTION3 = Get-CMDeviceCollection -Name "3 - Chris Kearns Org [OLD]"
$COMPLIST3 = Import-Csv -Path "D:\Users\206676599\OneDrive - NBCUniversal\Scripts\script reference\working\3 - Chris Kearns Org OLD.csv" -Header Collection,Computers

foreach ($COMP in $COMPLIST3) {
    $COMPNAME = $Comp.Computers
    $COMPOBJ = Get-CMDevice -Name $COMPNAME
    Write-Output "---Adding direct membership of $COMP. - $DATE---" | Out-File $FULLLOGPATH -Append -Force -NoClobber
    Add-CMDeviceCollectionDirectMembershipRule -InputObject $COLLECTION3 -Resource $COMPOBJ | Out-File $FULLLOGPATH -Append -Force -NoClobber
}

#5 - Keith Jackson - All
$COLLECTION5 = Get-CMDeviceCollection -Name "5 - Keith Jackson - All"
$COMPLIST5 = Import-Csv -Path "D:\Users\206676599\OneDrive - NBCUniversal\Scripts\script reference\working\5 - Keith Jackson - All.csv" -Header Collection,Computers

foreach ($COMP in $COMPLIST5) {
    $COMPNAME = $Comp.Computers
    $COMPOBJ = Get-CMDevice -Name $COMPNAME
    Write-Output "---Adding direct membership of $COMP. - $DATE---" | Out-File $FULLLOGPATH -Append -Force -NoClobber
    Add-CMDeviceCollectionDirectMembershipRule -InputObject $COLLECTION5 -Resource $COMPOBJ | Out-File $FULLLOGPATH -Append -Force -NoClobber
}

#6 - Ian Trombley - All
$COLLECTION6 = Get-CMDeviceCollection -Name "6 - Ian Trombley - All"
$COMPLIST6 = Import-Csv -Path "D:\Users\206676599\OneDrive - NBCUniversal\Scripts\script reference\working\6 - Ian Trombley - All.csv" -Header Collection,Computers

foreach ($COMP in $COMPLIST6) {
    $COMPNAME = $Comp.Computers
    $COMPOBJ = Get-CMDevice -Name $COMPNAME
    Write-Output "---Adding direct membership of $COMP. - $DATE---" | Out-File $FULLLOGPATH -Append -Force -NoClobber
    Add-CMDeviceCollectionDirectMembershipRule -InputObject $COLLECTION6 -Resource $COMPOBJ | Out-File $FULLLOGPATH -Append -Force -NoClobber
}



Write-Output "---Completed adding direct membership of devices. - $DATE---" | Out-File $FULLLOGPATH -Append -Force -NoClobber