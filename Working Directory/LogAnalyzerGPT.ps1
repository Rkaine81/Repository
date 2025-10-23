# Define the path to the Configuration Manager client logs
$logPath = "C:\Windows\CCM\Logs"
# Get the current date and time
$currentDate = Get-Date
# Get logs modified in the last 24 hours
$recentLogs = Get-ChildItem -Path $logPath -Filter *.log | Where-Object { $_.LastWriteTime -ge $currentDate.AddHours(-24) }
# Initialize a hash table to store error counts
$errorCounts = @{}
# Define a regex pattern to identify errors in the logs
$errorPattern = "(?i)error"
# Analyze each log file
foreach ($log in $recentLogs) {
   $logContent = Get-Content -Path $log.FullName
   foreach ($line in $logContent) {
       if ($line -match $errorPattern) {
           $errorText = $matches[0]
           if (-not $errorCounts.ContainsKey($errorText)) {
               $errorCounts[$errorText] = [PSCustomObject]@{
                   ErrorMessage = $errorText
                   Count = 1
                   LogFiles = @($log.FullName)
               }
           } else {
               $errorCounts[$errorText].Count++
               if (-not $errorCounts[$errorText].LogFiles -contains $log.FullName) {
                   $errorCounts[$errorText].LogFiles += $log.FullName
               }
           }
       }
   }
}
# Output each unique error to the screen
foreach ($key in $errorCounts.Keys) {
   $errorItem = $errorCounts[$key]
   Write-Host "Error: $($errorItem.ErrorMessage)"
   Write-Host "Count: $($errorItem.Count)"
   Write-Host "Log Files: $($errorItem.LogFiles -join ', ')"
   Write-Host ""
}
# Convert the hash table to an array of objects for easier CSV export
$output = foreach ($key in $errorCounts.Keys) {
   [PSCustomObject]@{
       ErrorMessage = $errorCounts[$key].ErrorMessage
       Count = $errorCounts[$key].Count
       LogFiles = ($errorCounts[$key].LogFiles -join ", ")
   }
}
# Define the path to the output CSV file
$outputCsvPath = "C:\logs\ErrorReport.csv"
# Export the results to a CSV file
$output | Export-Csv -Path $outputCsvPath -NoTypeInformation
Write-Host "Error analysis completed. Results saved to $outputCsvPath"