#
# Press 'F5' to run this script. Running this script will load the ConfigurationManager
# module for Windows PowerShell and will connect to the site.
#
# This script was auto-generated at '7/25/2024 10:14:55 PM'.

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

$collName = "M365 Devices"
$Bline = 'COMPLIANCE - Classic Outlook Running'

function Invoke-BLEvaluation {
    param (
        [String][Parameter(Mandatory=$true, Position=1)] $ComputerName,
        [String][Parameter(Mandatory=$False, Position=2)] $BLName
    )
    If ($BLName -eq $Null) {
        $Baselines = Get-WmiObject -ComputerName $ComputerName -Namespace root\ccm\dcm -Class SMS_DesiredConfiguration
    }Else{
        $Baselines = Get-WmiObject -ComputerName $ComputerName -Namespace root\ccm\dcm -Class SMS_DesiredConfiguration | Where-Object {$_.DisplayName -like $BLName}
    }
 
    $Baselines | % {
        ([wmiclass]"\\$ComputerName\root\ccm\dcm:SMS_DesiredConfiguration").TriggerEvaluation($_.Name, $_.Version) 
    }
 
}


$SiteCode = "P01" 
$ProviderMachineName = "DCVWP-SCCMAP01.choa.org" 
$initParams = @{}
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}
Set-Location "$($SiteCode):\" @initParams

$trigger = "{00000000-0000-0000-0000-000000000021}"


$collObj = Get-CMDeviceCollection -Name $collName
$PCs = Get-CMCollectionMember -InputObject $collObj

foreach ($pc in $PCs) {
#    $PCName = "$($pc.Name).ambh.choa.org"
    $PCName = $pc.Name

    Invoke-WmiMethod -ComputerName $PCName -Namespace root\ccm -Class sms_client -Name TriggerSchedule $trigger

    Start-Sleep -Seconds 60

    Invoke-BLEvaluation -ComputerName $PCName -BLName $Bline
}