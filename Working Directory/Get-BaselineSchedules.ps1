#
# Press 'F5' to run this script. Running this script will load the ConfigurationManager
# module for Windows PowerShell and will connect to the site.
#
# This script was auto-generated at '4/3/2025 2:14:49 PM'.

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


# === Get all Configuration Baselines ===
$baselines = Get-CMBaseline -Fast
# === Initialize Result Collection ===
$results = @()
foreach ($baseline in $baselines) {
   # Get deployments of the current baseline
   $deployments = Get-WmiObject -Namespace "root\SMS\site_$siteCode" -Query "SELECT * FROM SMS_BaselineDeployment WHERE ConfigurationBaselineID = '$($baseline.CI_ID)'"
   foreach ($deployment in $deployments) {
       $schedule = $deployment.AssignmentSchedule | ForEach-Object {
           try {
               [System.Management.ManagementDateTimeConverter]::ToDateTime($_)
           } catch {
               "Invalid/Custom Schedule"
           }
       }
       $results += [PSCustomObject]@{
           BaselineName = $baseline.LocalizedDisplayName
           Schedule     = ($schedule -join ", ")
       }
   }
}
# === Output Results ===
$results | Format-Table -AutoSize
# === Optional: Export to CSV ===
# $results | Export-Csv -Path "BaselineDeployments.csv" -NoTypeInformation
