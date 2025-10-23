# Citrix Client Health Remediation Script
# Function to start a process if not running
function Start-ProcessIfNotRunning {
   param (
       [string]$processName,
       [string]$processPath
   )
   $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
   if (!$process) {
       Start-Process $processPath
       Write-Host "Started $processName"
   } else {
       Write-Host "$processName is already running"
   }
}
# Function to start a service if not running
function Start-ServiceIfNotRunning {
   param (
       [string]$serviceName
   )
   $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
   if ($service -and $service.Status -ne 'Running') {
       Start-Service $serviceName
       Write-Host "Started $serviceName"
   } else {
       Write-Host "$serviceName is already running"
   }
}
# Define the Citrix processes and services to check
$citrixProcesses = @(
   "wfcrun32",
   "Receiver",
   "SelfServicePlugin",
   "CitrixReceiverUpdater"
)
$citrixProcessPaths = @(
   "C:\Program Files (x86)\Citrix\ICA Client\wfcrun32.exe",
   "C:\Program Files (x86)\Citrix\Receiver\Receiver.exe",
   "C:\Program Files (x86)\Citrix\SelfServicePlugin\SelfServicePlugin.exe",
   "C:\Program Files (x86)\Citrix\CitrixReceiverUpdater\CitrixReceiverUpdater.exe"
)
$citrixServices = @(
   "CtxAudioSvc",
   "Citrix Indirect Display Adapter",
   "Citrix USB Device Redirection",
   "Citrix HDX HTML5 Video Redirection",
   "Citrix HDX Audio Service"
)
# Start Citrix processes if not running
for ($i = 0; $i -lt $citrixProcesses.Length; $i++) {
   Start-ProcessIfNotRunning -processName $citrixProcesses[$i] -processPath $citrixProcessPaths[$i]
}
# Start Citrix services if not running
foreach ($service in $citrixServices) {
   Start-ServiceIfNotRunning -serviceName $service
}