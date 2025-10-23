# Generate the Windows Update log file
Get-WindowsUpdateLog -LogPath "C:\WindowsUpdate.log"
# Define the path to the Windows Update log file
$logPath = "C:\WindowsUpdate.log"
# Read the log file
$logContent = Get-Content -Path $logPath
# Define a regex pattern to match the successful update entries
$pattern = "Installation Successful: Windows successfully installed the following update:"
# Initialize variables to store the last successful update details
$lastUpdate = $null
$lastDate = $null
# Loop through the log content and find the last successful update
foreach ($line in $logContent) {
   if ($line -match $pattern) {
       $lastUpdate = $line
       $lastDate = $line.Substring(0, 19)  # Extract the date and time from the log line
   }
}
# Extract the update details (name and KB number) from the last successful update entry
if ($lastUpdate -ne $null) {
   $updateDetails = $lastUpdate -replace ".*Installation Successful: Windows successfully installed the following update: ", ""
   $updateName = $updateDetails -replace "\(KB[0-9]+\)", ""
   $kbNumber = if ($updateDetails -match "\((KB[0-9]+)\)") { $matches[1] } else { "N/A" }
   # Output the results
   Write-Host "Last successful update:"
   Write-Host "Update Name: $updateName"
   Write-Host "KB Number: $kbNumber"
   Write-Host "Installed Date: $lastDate"
} else {
   Write-Host "No successful updates found in the log."
}