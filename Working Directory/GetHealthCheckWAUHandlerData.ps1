# Set the directory path to search
$directoryPath = "\\choa-cifs\install\WindowsLogs\ClientHealth"   # Update with your target directory
$outputFilePath = "C:\choa\WAUHandlerRepair.txt"  # Update with desired output path
# Remove existing output file if it exists to avoid appending old data
if (Test-Path -Path $outputFilePath) {
   Remove-Item -Path $outputFilePath
}
# Define file size in bytes
$targetSize = 3000
# Search for files in the specified directory
$Files = Get-ChildItem -Path $directoryPath -File -Recurse

ForEach ($file in $files) {
   # Check if the file is about 3K
   if ($file.Length -lt $targetSize) {
       # Read file contents
       #Write-Output $file.Name
       $fileContent = Get-Content -Path $file.FullName -Raw
       # Check if the specific line exists in the file
       if ($fileContent -match 'WUAHandler: Repaired.*') {
           Write-Output $file.Name
           # Output the file name to the text file
           Add-Content -Path $outputFilePath -Value $file.Name
       }
   }
}
Write-Output "Script complete. Files containing 'WAUHandler:Repaired' have been saved to $outputFilePath."
