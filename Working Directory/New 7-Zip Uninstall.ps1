# Define output directory
$OutputDir = "C:\CHOA"
$Date = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LogDir = Join-Path $OutputDir "LogCollection"
# Ensure the output directory exists
if (-not (Test-Path -Path $LogDir)) {
   New-Item -ItemType Directory -Path $LogDir -Force
}
# Logging helper function
function LogMessage {
   param([string]$Message)
   Write-Output $Message
   $Message | Out-File -FilePath (Join-Path $LogDir "7-Zip_Log.log") -Append -Force
}
LogMessage "Script started at $Date."
LogMessage "Logs will be saved in $LogDir."
# Function to clean registry keys for a given application
function CleanRegistryKeys {
   param([string]$ApplicationName)
   LogMessage "Checking for registry keys related to $ApplicationName..."
   # Define registry locations to check for uninstall keys
   $RegistryPaths = @(
       "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
       "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
       "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
   )
   foreach ($Path in $RegistryPaths) {
       try {
           # Get all uninstall keys
           $UninstallKeys = Get-ChildItem -Path $Path -ErrorAction SilentlyContinue
           foreach ($Key in $UninstallKeys) {
               # Check if the key contains the application name
               $KeyValue = (Get-ItemProperty -Path $Key.PSPath -ErrorAction SilentlyContinue)
               if ($KeyValue.DisplayName -like "*$ApplicationName*") {
                   LogMessage "Found registry key for $($ApplicationName): $($Key.PSPath)"
                   # Attempt to remove the key
                   try {
                       Remove-Item -Path $Key.PSPath -Recurse -Force
                       LogMessage "Successfully removed registry key: $($Key.PSPath)"
                   } catch {
                       LogMessage "Error removing registry key: $($Key.PSPath). Error: $_"
                   }
               }
           }
       } catch {
           LogMessage "Error accessing registry path $Path. Error: $_"
       }
   }
}
# Example: Cleaning registry keys for 7-Zip
$ApplicationName = "7-Zip"
LogMessage "Starting cleanup for $ApplicationName..."
# 1. Check for any installed versions
LogMessage "Checking for installed versions of $($ApplicationName)..."
$InstalledApps = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*$ApplicationName*" }
if ($InstalledApps) {
   foreach ($App in $InstalledApps) {
       LogMessage "Found installed version: $($App.Name)"
       # Attempt to uninstall
       LogMessage "Uninstalling $($App.Name)..."
       try {
           $App.Uninstall() | Out-Null
           LogMessage "Successfully uninstalled: $($App.Name)"
       } catch {
           LogMessage "Error uninstalling: $($App.Name). Error: $_"
       }
   }
} else {
   LogMessage "No installed versions of $ApplicationName found."
}
# 2. Check and clean up registry keys
CleanRegistryKeys -ApplicationName $ApplicationName
# 3. Check for pending reboot
LogMessage "Checking for pending reboot status..."
try {
   $PendingReboot = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -ErrorAction SilentlyContinue
   if ($PendingReboot) {
       LogMessage "A pending reboot is detected."
   } else {
       LogMessage "No pending reboot detected."
   }
} catch {
   LogMessage "Error checking pending reboot status: $_"
}
# 4. Final cleanup and compression of logs
LogMessage "Compressing log files..."
try {
   $ZipFile = Join-Path $OutputDir "LogCollection_$Date.zip"
   Compress-Archive -Path $LogDir\* -DestinationPath $ZipFile -Force
   LogMessage "Logs compressed into $ZipFile"
} catch {
   LogMessage "Error compressing logs: $_"
}
LogMessage "Script execution completed. Logs collected in $($LogDir)."
# 5. Verification Step
LogMessage "Checking for installed versions of $($ApplicationName)..."
$InstalledApps = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*$ApplicationName*" }
if ($InstalledApps) {
   foreach ($App in $InstalledApps) {
       LogMessage "Found installed version: $($App.Name).  Script Failed."
   }
} else {
   LogMessage "No installed versions of $ApplicationName found."
   New-Item -Path HKLM:\SOFTWARE\CHOA\7-Zip_Removed -Force
}