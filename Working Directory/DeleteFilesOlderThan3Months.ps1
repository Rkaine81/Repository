# Define the folder path
$folderPath = "C:\Users\179944\Downloads\new"
# Get the first day of the current month
$currentMonthStart = Get-Date -Day 1
# Calculate the threshold date (first day of the month, three months ago)
$thresholdDate = $currentMonthStart.AddMonths(-3)
# Get all the files in the folder and its subfolders recursively
$files = Get-ChildItem -Path $folderPath -Recurse -File
# Loop through each file and check its creation time
foreach ($file in $files) {
   # Get the file creation time
   $creationTime = $file.CreationTime
   # Check if the file was created more than three months before the current month
   if ($creationTime -lt $thresholdDate) {
       # Delete the file
       Remove-Item $file.FullName -Force
       Write-Host "Deleted file: $($file.FullName)"
   }
}