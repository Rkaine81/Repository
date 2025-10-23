#Script Name: DeleteUnknownComputers.ps1
#Script Version: 2.0
#Author: Adam Eaddy
#Date Created: 03/10/2021
#Description: This script will delete the "Unknown" computer records in the "Unknown Computers to be Deleted" device collection.
#Changes:06/04/2021 - 2.0 - Added log cleanup.

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


# Set the current location to be the site code.
Set-Location "$($SiteCodeCAS):\" @initParams


$DATE = Get-Date
$SDATE = get-date -Format MMddyyyy
$LOGPATH = $env:TEMP
$LOGFILE = "Unknown_Computer_Delete_Log_$SDATE.log"
$FULLLOGPATH = "$LOGPATH\$LOGFILE"

#Check for Log and delete is exists
$OLDLOGS = Get-Item -Path "$LOGPATH\Unknown_Computer_Delete_Log*"
$YESTERDAY = (get-date).AddDays(-1).ToString("MMddyyyy")
$2DAYS = (get-date).AddDays(-2).ToString("MMddyyyy")
$YESTERDAYSLOG = "Unknown_Computer_Delete_Log_$YESTERDAY.log"
$2DAYLOG = "Unknown_Computer_Delete_Log_$2DAYS.log"

foreach ($OLDLOG in $OLDLOGS) {
    

    if ($OLDLOG.Name -ne $YESTERDAYSLOG -and $OLDLOG.Name -ne $2DAYLOG){
        Remove-Item $OLDLOG
        write-output "Deleteing $($OLDLOG.Name)"
    }
}

Write-Output "---Begining ""Unknown"" computer cleanup script - $DATE---" | Out-File $FULLLOGPATH -Append -Force -NoClobber

$UCL = Get-CMCollectionMember -CollectionName "Unknown Computers to be Deleted"

foreach ($UC in $UCL) {
Write-Output "Deleting unknown computer object with MAC address: $($UC.MACAddress)." | Out-File $FULLLOGPATH -Append -Force -NoClobber
Remove-CMDevice -InputObject $UC -Force
}

Write-Output "---Finishing ""Unknown"" computer cleanup script - $DATE---" | Out-File $FULLLOGPATH -Append -Force -NoClobber