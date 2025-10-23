# File: RebootToast.ps1
param (
   [string]$action = ""
)
# === Configuration ===
$folderPath = "C:\Temp\DeleteMe"
$registryPath = "HKCU:\Software\MyApp"
$registryName = "RebootFlag"
$registryValue = "Rebooted"
function Execute-RebootTasks {
   Remove-Item -Path $folderPath -Recurse -Force -ErrorAction SilentlyContinue
   New-Item -Path $registryPath -Force | Out-Null
   Set-ItemProperty -Path $registryPath -Name $registryName -Value $registryValue
   Restart-Computer -Force
}
# === Handle toast actions ===
if ($action -eq "now") {
   Execute-RebootTasks
   exit
} elseif ($action -eq "later") {
   Start-Sleep -Seconds 1800
   Execute-RebootTasks
   exit
}
# === Show toast ===
$scriptPath = $MyInvocation.MyCommand.Definition.Replace('"', '""')
# Build the XML toast
$toastXml = @"
<toast>
<visual>
<binding template="ToastGeneric">
<text>Reboot Required</text>
<text>Your device needs to be restarted to finish updates.</text>
</binding>
</visual>
<actions>
<action
     content="Reboot Now"
     arguments="powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`" -action now"
     activationType="foreground"/>
<action
     content="Reboot in 30 Minutes"
     arguments="powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`" -action later"
     activationType="foreground"/>
</actions>
</toast>
"@
# === Display toast notification ===
Add-Type -AssemblyName System.Runtime.WindowsRuntime
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
$xmlDoc = New-Object Windows.Data.Xml.Dom.XmlDocument
$xmlDoc.LoadXml($toastXml)
$toast = [Windows.UI.Notifications.ToastNotification]::new($xmlDoc)
$notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("RebootNotification")
$notifier.Show($toast)