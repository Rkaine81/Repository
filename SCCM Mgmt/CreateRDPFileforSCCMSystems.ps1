#Script Name: CreateRDPFileforSCCMSystems.ps1
#Script Version: 1.0
#Author: Adam Eaddy
#Date Created: 03/10/2021
#Description: This script will list all of the site servers for all of the sites and create a .RDP file with the provided user account.
#             Files and logs can be found in %TEMP% and %TEMP%\RDP.
#             Populate the user account you want embedded in the RDP session file. (e.g. "tfayd\206600001")
#Changes:


#Provide User Account
$USERACCOUNT = "tfayd\XXXX"

#Define Logging
$DATE = Get-Date
$SDATE = get-date -Format MMddyyyy
$LOGPATH = $env:TEMP
$LOGFILE = "MEMCMRDPServerSessionFiles_$SDATE.log"
$FULLLOGPATH = "$LOGPATH\$LOGFILE"
$RDPFILEPATH = "$env:TEMP\RDP"
If(Test-Path $RDPFILEPATH) { write-output "The Logpath is: $LOGPATH, and the RDP files will be stored at: $RDPFILEPATH." } Else { New-Item -ItemType Directory -Path $LOGPATH -Name "RDP"}  



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




#Begin Code
Write-Output "---Begin creating RDP session files for MEMCM Site Servers and user $USERACCOUNT - $DATE---" | Out-File $FULLLOGPATH -Append -Force -NoClobber

foreach ($SITE in $SITELIST) {

    Set-Location "$($SITE):\" @initParams

    $SITESERVERS = (Get-CMSiteSystemServer).NetworkOSPath.trimstart("\\")

    foreach ($SITESERVER in $SITESERVERS) {
    Write-Output "Creating RDP session file for $SITESERVER." | Out-File $FULLLOGPATH -Append -Force -NoClobber

    $RDPFILE = "gatewaybrokeringtype:i:0
use redirection server name:i:0
disable themes:i:0
disable cursor setting:i:0
disable menu anims:i:1
remoteapplicationcmdline:s:
audiocapturemode:i:0
prompt for credentials on client:i:0
remoteapplicationprogram:s:
gatewayusagemethod:i:2
screen mode id:i:2
use multimon:i:0
authentication level:i:2
desktopwidth:i:800
desktopheight:i:600
redirectclipboard:i:1
enablecredsspsupport:i:1
promptcredentialonce:i:0
redirectprinters:i:0
autoreconnection enabled:i:1
administrative session:i:0
redirectsmartcards:i:0
authoring tool:s:
alternate shell:s:
remoteapplicationmode:i:0
disable full window drag:i:1
gatewayusername:s:
shell working directory:s:
audiomode:i:0
username:s:$USERACCOUNT
allow font smoothing:i:1
connect to console:i:0
gatewayhostname:s:
drivestoredirect:s:
session bpp:i:32
disable wallpaper:i:0
full address:s:$SITESERVER
gatewayaccesstoken:s:
winposstr:s:0,3,0,0,800,600
compression:i:1
keyboardhook:i:2
videoplaybackmode:i:1
connection type:i:7
networkautodetect:i:1
bandwidthautodetect:i:1
displayconnectionbar:i:1
enableworkspacereconnect:i:0
allow desktop composition:i:0
bitmapcachepersistenable:i:1
redirectcomports:i:0
redirectposdevices:i:0
prompt for credentials:i:0
negotiate security layer:i:1
gatewaycredentialssource:i:4
gatewayprofileusagemethod:i:0
rdgiskdcproxy:i:0
kdcproxyname:s:"

    $SERVER = $SITESERVER.ToLower()
    $RDPFILENAME = $SERVER + ".rdp"
    $FULLRDPFILEPATH = "$RDPFILEPATH\$RDPFILENAME"
    Write-Output $RDPFILE | Out-File $FULLRDPFILEPATH

    }

}

#End of script
Write-Output "---Finish creating RDP session files for MEMCM Site Servers - $DATE---" | Out-File $FULLLOGPATH -Append -Force -NoClobber