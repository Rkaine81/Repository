# Define the directory to scan for files
$directoryPath = "C:\Path\To\Your\Directory"  # Replace with your directory path
# Define the output CSV file path
$outputCsvPath = "C:\Path\To\Output\size_matches.csv"  # Replace with your desired output CSV path
# Initialize an array to store results
$results = @()
# Get all files in the specified directory
$files = Get-ChildItem -Path $directoryPath -File
# Loop through each file and search for "size="
foreach ($file in $files) {
   # Use Select-String to find the line that contains "size="
   $matches = Select-String -Path $file.FullName -Pattern "size="
   foreach ($match in $matches) {
       # Extract the content after "size="
       if ($match -match 'size=([^ ]+)') {
           $sizeValue = $matches.Matches[0].Groups[1].Value
           # Store the filename and size value in a custom object
           $results += [PSCustomObject]@{
               FileName = $file.Name
               SizeValue = $sizeValue
           }
       }
   }
}
# Export results to a CSV file
$results | Export-Csv -Path $outputCsvPath -NoTypeInformation
Write-Host "Results exported to $outputCsvPath"