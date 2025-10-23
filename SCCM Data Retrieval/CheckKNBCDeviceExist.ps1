#
# Press 'F5' to run this script. Running this script will load the ConfigurationManager
# module for Windows PowerShell and will connect to the site.
#
# This script was auto-generated at '3/3/2021 9:11:40 AM'.

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

$KNBCCOMPS = "NUTBURLMNL21WL",
"NUTBURLMNL09WL",
"NUTBURLMNL18WL",
"NUTBURLMNL22WL",
"NUTBURLMNL12BWL",
"NUTBURF74SGH2",
"NUTBURLMNL10WL",
"NUUUUCBCNL407L",
"NUTBURLMNL17WL",
"KNBC4SXCVF2L",
"NUTBURLMNL26WL",
"NEWSLAPTOP0001W",
"UCKNBCTEST29W7",
"NUTBURLMNL08W",
"NUTBURLMNL33WL",
"NUTBURLMNL02WL",
"KNBCNWSLPT02WL",
"NUTUCTLNL507L",
"KNBCNWSLPT04WL",
"KNBCNWSLPT07WL",
"KNBCNWSLPT12WL",
"NUTBURLMNL35WL",
"NUTBURLMNL13WL",
"NUTBURLMNL07WL",
"NUTBURLMNL20WL",
"DBWBB64RGH2",
"NUTUCTLNL647L",
"NUUUUCBCNL0307L",
"NUUUUCBCNL0317L",
"NUTBURLMNL23WL",
"NUTBURLMNL29WL",
"NUTBURLMNL04WL",
"KNBCNWSLPT10WL",
"NUTBURLMNL31WL",
"NUTBURLMNL25AWL",
"KNBC7RTBVF2L",
"NUTUCTLNL487L",
"NUTUCTLNL617L",
"UCKNBCTEST23W7",
"KVEANWSLPT02WL",
"KVEANWSLPT05WL",
"NUTUCTLNL507L",
"NUTUCTLNL567L",
"NUTUCTLNL627L",
"NUTUCTLNL517L",
"NUTUCTLNL447L",
"NUTUCTLNL497L",
"NUTUCTLNL457",
"NUTUCTLNL567L",
"NUTBURLOANERS",
"KNBC4B5QVF2L",
"NUTBURLMNL26BWL",
"KNBCNWSLPT09WL",
"KNBC3WC7GH2L",
"KNBC7CZQGH2L",
"KNBCFKTBVF2L",
"NUTBURJZ5SGH2",
"KNBCNWSLPT11WL",
"NUTBURLMNL24WL",
"KNBCNWSLPT11WL",
"NUTUCTLNL487L",
"NUTBURLMNL16W",
"KNBC8S2WWZ1L",
"NUUUUCBCNL027L",
"NUTBURKVEA18",
"NUTUCTLNL607L",
"NUTUCTLNL467L",
"NUTUCTLNL487L",
"KNBCMMLAPTOP01",
"KNBCD9X2BZ1WL"

foreach ($KNBCCOMP in $KNBCCOMPS) {
    #Write-Output "The device name is: $KNBCCOMP"
    $DEVICE = $null
    $DEVICE = get-cmdevice -Name $KNBCCOMP
    if ($DEVICE -eq $null) {
        Write-Output "$KNBCCOMP is not in SCCM - Error" | out-file c:\temp\working\KNBC.log -Append -Force -NoClobber
    }else{
        if ($Device.ClientType -eq 1) {
            Write-Output "$KNBCCOMP is an active device." | out-file c:\temp\working\KNBC.log -Append -Force -NoClobber
        }else{
            Write-Output "$KNBCCOMP is in the console with no agent. - Warning" | out-file c:\temp\working\KNBC.log -Append -Force -NoClobber
        }
    }
}

