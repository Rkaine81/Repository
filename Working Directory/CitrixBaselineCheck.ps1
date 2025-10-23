# Citrix Client Health Check Configuration Item Script
$Result = @()
# Check if Citrix Receiver or Workspace is installed
$citrixKey = "HKLM:\SOFTWARE\WOW6432Node\Citrix\Dazzle"
if (Test-Path $citrixKey) {
   $Result += "Citrix Receiver/Workspace is installed"
} else {
   $Result += "Citrix Receiver/Workspace is not installed"
}
# Define the Citrix processes and services to check
$citrixProcesses = @(
   "wfcrun32",
   "Receiver",
   "SelfServicePlugin",
   "CitrixReceiverUpdater"
)
$citrixServices = @(
   "CtxAudioSvc",
   "Citrix Indirect Display Adapter",
   "Citrix USB Device Redirection",
   "Citrix HDX HTML5 Video Redirection",
   "Citrix HDX Audio Service"
)
# Check Citrix processes
foreach ($process in $citrixProcesses) {
   $proc = Get-Process -Name $process -ErrorAction SilentlyContinue
   if ($proc) {
       $Result += "$process is running"
   } else {
       $Result += "$process is not running"
   }
}
# Check Citrix services
foreach ($service in $citrixServices) {
   $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
   if ($svc -and $svc.Status -eq 'Running') {
       $Result += "$service is running"
   } else {
       $Result += "$service is not running"
   }
}
# Output result
if ($Result -like "*not installed" -or $Result -like "*not running") {
   Write-Host "NonCompliant"
   Write-Output $Result
} else {
   Write-Host "Compliant"
}