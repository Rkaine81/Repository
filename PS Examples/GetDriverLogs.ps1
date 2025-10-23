# Define the directory to scan and the reference file
$sourceDirectory = "\\choa-cifs\install\WindowsLogs\DriverLogs"
$referenceFile = "C:\Temp\results\Drivers2.txt"
# Ensure the reference file exists (create if it doesn't)
if (-not (Test-Path $referenceFile)) {
   New-Item -ItemType File -Path $referenceFile | Out-Null
}
# Loop through each file in the source directory
Get-ChildItem -Path $sourceDirectory -File | ForEach-Object {
   $file = $_.FullName
   # Read each line in the current file
   Get-Content -Path $file | ForEach-Object {
       $line = $_
       # Check if the line starts with "--"
       if ($line -match "^\-\-") {
           # Escape the line to safely use as a regex pattern
           $escapedLine = [regex]::Escape($line)
           # Check if the line already exists in the reference file
           if (-not (Select-String -Path $referenceFile -Pattern $escapedLine -Quiet)) {
               # Append the line to the reference file
               Add-Content -Path $referenceFile -Value $line
           }
       }
   }
}
Write-Host "Processing complete. Lines starting with '--' have been checked and added to the reference file if not present."