# Define log file path
$logPath = "C:\CHOA\chrome_scan.log"
# Create log directory if it doesn't exist
if (!(Test-Path -Path (Split-Path $logPath))) {
   New-Item -Path (Split-Path $logPath) -ItemType Directory | Out-Null
}
# Log a message to the log file
function Log-Message {
   param (
       [string]$message
   )
   Add-Content -Path $logPath -Value "$([DateTime]::Now): $message"
}
# Start scanning user directories
$userDirs = Get-ChildItem -Path "C:\Users" -Directory -Force
foreach ($userDir in $userDirs) {
   Log-Message "Scanning directory: $($userDir.FullName)"
   # Search recursively including hidden directories for chrome.dll
   $files = Get-ChildItem -Path $userDir.FullName -Recurse -Force -Filter "chrome.dll" -ErrorAction SilentlyContinue
   foreach ($file in $files) {
       try {
           # Log that the file was found
           Log-Message "warning: Found chrome.dll in $($file.FullName)"
           # Attempt to delete the file
           Remove-Item -Path $file.FullName -Force
           # Log successful deletion
           Log-Message "warning: Deleted chrome.dll from $($file.FullName)"
       } catch {
           # Log any failure to delete the file
           Log-Message "Failed to delete chrome.dll from $($file.FullName): $($_.Exception.Message)"
       }
   }
}
Log-Message "Scan complete."