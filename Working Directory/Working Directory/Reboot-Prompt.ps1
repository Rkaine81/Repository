# File: PromptReboot.ps1
Add-Type -AssemblyName PresentationFramework
# Constants
$folderPath = "C:\Path\To\Folder"
$regPath = "HKCU:\Software\MyCompany\MyApp"
$regName = "RebootPending"
$regValue = "true"
# Function to delete folder if exists
function Delete-Folder {
   if (Test-Path $folderPath) {
       Remove-Item -Path $folderPath -Recurse -Force
   }
}
# Function to delete registry key if exists
function Delete-RegistryKey {
   if (Test-Path $regPath) {
       Remove-Item -Path $regPath -Recurse -Force
   }
}
# Function to create registry key
function Create-RegistryKey {
   if (-not (Test-Path $regPath)) {
       New-Item -Path $regPath -Force | Out-Null
   }
   Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -Force
}
# Main Prompt
$choice = [System.Windows.MessageBox]::Show("Would you like to reboot now or in 30 minutes?", "Reboot Required", "YesNo", "Question")
if ($choice -eq "Yes") {
   Delete-Folder
   Delete-RegistryKey
   Restart-Computer -Force
}
else {
   Start-Sleep -Seconds 1800
   Delete-Folder
   Create-RegistryKey
   [System.Windows.MessageBox]::Show("Rebooting in 30 seconds...", "Final Warning", "OK", "Warning") | Out-Null
   Start-Sleep -Seconds 30
   Restart-Computer -Force
}