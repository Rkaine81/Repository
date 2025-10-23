#Script Name: SplitCSVbyCollection.ps1
#Script Version: 1.0
#Author: Adam Eaddy
#Date Created: 03/15/2021
#Description: This script will split the DirectMembership CSV into individual CSV files.
#Changes:

$FULLCSVPATH = "C:\TEMP\RunningScripts\Collection and Machine retrival.csv"

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
$LOGPATH = "C:\TEMP\RunningScripts"
#Set Log name
$LOGFILE = "SplitCSVbyCollection_$SDATE.log"
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
        $NEWCSV = "$COLLNAME1.csv"
        $NEWCSVTRIM = $NEWCSV -Replace'[\[\]\{\}\(\)!@#$%^:&*~]',''
        $CSVPATH = "C:\TEMP\RunningScripts"
        $NEWCSVPATH = "$CSVPATH\$NEWCSVTRIM"
        write-output "Collection,Computer" | out-file $FULLCSVPATH -Force -Append -NoClobber
    }

    Write-Output "---Adding direct membership of $COMPNAME to $COLLNAME1. - $(get-date)---" | Out-File $FULLLOGPATH -Append -Force -NoClobber
    #Add-CMDeviceCollectionDirectMembershipRule -InputObject $COLLECTION -Resource $COMPOBJ | Out-File $FULLLOGPATH -Append -Force -NoClobber
    Write-Output "$COLLNAME1,$COMPNAME" | Out-File $NEWCSVPATH -Append -Force -NoClobber
    Write-Output "$NEWCSVPATH, $COLLNAME1, $COMPNAME"
}

Write-Output "---Completed adding direct membership of devices. - $(get-date)---" | Out-File $FULLLOGPATH -Append -Force -NoClobber


