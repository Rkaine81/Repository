# Specify the directory containing the log files
$logDirectory = "C:\Temp\andor reboot logs"

# Specify the output CSV file
$outputCsv = "C:\Temp\andor reboot logs\output.csv"

# Initialize an array to hold the results
$results = @()

# Get all log files from the directory
$logFiles = Get-ChildItem -Path $logDirectory -Filter "*-EventID1074.log"

# Loop through each log file
foreach ($logFile in $logFiles) {
    # Extract the computer name from the file name
    $computerName = $logFile.Name -replace "-EventID1074\.log$", ""
    
    # Read the content of the log file
    $logContent = Get-Content -Path $logFile.FullName -Raw
    
    # Split the log content into entries
    $logEntries = $logContent -split "---------------------------------------"

    # Process each entry
    foreach ($entry in $logEntries) {
        # Check if the entry contains the specified Reason Code
        if ($entry -match "Reason Code: 0x500ff") {
            # Extract the date from the entry
            if ($entry -match "Date: (\d{2}/\d{2}/\d{4} \d{2}:\d{2}:\d{2})") {
                $date = $matches[1]

                # Add the computer name and date to the results
                $results += [PSCustomObject]@{
                    ComputerName = $computerName
                    Date         = $date
                }
            }
        }
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path $outputCsv -NoTypeInformation

Write-Host "Processing complete. Results saved to $outputCsv."