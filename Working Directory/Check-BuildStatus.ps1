# Define the applications to check
$apps = @(
"Configuration Manager Client",
"Microsoft Office",
"Teams",
"Trellix Agent",
"Trellix Data Loss prevention - endpoint",
"Trellix Management of Native Encryption",
"Qualys",
"Crowdstrike",
"Cisco Secure Client - AnyConnect VPN",
"Cisco Secure Client - Umbrella",
"Webex",
"Citrix Workspace",
"Microsoft Edge"
)
# Function to check if an application is installed
function Check-Application {
   param (
       [string]$appName
   )
   $installed = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
                Where-Object { $_.DisplayName -like "*$appName*" }
   if (-not $installed) {
       $installed = Get-ItemProperty HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
                    Where-Object { $_.DisplayName -like "*$appName*" }
   }
   return [bool]$installed
}
# Initialize results array
$results = @()
# Checking applications
$count = 0
$total = $apps.Count
foreach ($app in $apps) {
   $count++
   # Show progress bar
   $progress = [math]::Round(($count / $total) * 100)
   Write-Progress -Activity "Checking for $app..." -Status "$count of $total ($progress%)" -PercentComplete $progress
   # Check if the application is installed
   $isInstalled = Check-Application -appName $app
   # Store result
   $results += [PSCustomObject]@{
       Application = $app
       Status      = if ($isInstalled) { "Installed" } else { "Missing" }
   }
}
# Clear progress bar
Write-Progress -Activity "Checking installed applications complete." -Completed
# Display formatted checklist
Write-Host "`nApplication Installation Check:`n"
foreach ($result in $results) {
   if ($result.Status -eq "Installed") {
       Write-Host "✅ $($result.Application) - Installed" -ForegroundColor Green
   } else {
       Write-Host "❌ $($result.Application) - Missing" -ForegroundColor Red
   }
}
Write-Host "`nCheck complete!"

Read-Host "`nPress the Enter key to exit"