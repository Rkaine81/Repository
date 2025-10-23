# Set the root directory to start the scan
$rootDirectory = "C:\"
# Set the directories to exclude from the scan
$excludedDirectories = @("C:\Windows", "C:\Program Files", "C:\Program Files (x86)")
# Set the file name to search for
$fileToFind = "chromesetup.exe"
# Set the path for log files
$logDirectory = "C:\CHOA"
$logFile = "$logDirectory\ChromeSetup_scan_log.log"
# Ensure the log directory exists
if (-not (Test-Path $logDirectory)) {
   New-Item -Path $logDirectory -ItemType Directory
}




# Function to archive logs if older than a week
function Roll-Logs {
   param (
       [string]$logDir,
       [string]$logFileName
   )
   # Check if the log file exists
   if (Test-Path "$logDir\$logFileName") {
       # Get the log file's creation date
       $logCreationDate = (Get-Item "$logDir\$logFileName").CreationTime
       # If the log file is older than a week, archive it and create a new log
       if ((Get-Date) -gt $logCreationDate.AddDays(7)) {
           $archiveName = "$logDir\scan_log_$(Get-Date -Format yyyyMMdd_HHmmss).txt"
           Rename-Item -Path "$logDir\$logFileName" -NewName $archiveName
           New-Item -Path "$logDir\$logFileName" -ItemType File
       }
   } else {
       # Create a new log file if it doesn't exist
       New-Item -Path "$logDir\$logFileName" -ItemType File
   }
}




# Function to log activity
function Log-Entry {
   param (
       [string]$message
   )
   $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
   $entry = "$timestamp - $message"
   Add-Content -Path $logFile -Value $entry
}

# Function to search for the file and delete it if found
function Search-And-DeleteFile {
   param (
       [string]$rootDir,
       [string[]]$excludedDirs,
       [string]$fileName
   )
   # Get all directories under the root directory, excluding the ones in the exclusion list
   $dirsToSearch = Get-ChildItem -Path $rootDir -Directory -Recurse | Where-Object {
       $_.FullName -notin $excludedDirs
   }
   # Add the root directory itself to be searched
   $dirsToSearch += Get-Item $rootDir
   # Iterate through each directory and search for the file
   foreach ($dir in $dirsToSearch) {
       $files = Get-ChildItem -Path $dir.FullName -Filter $fileName -Recurse -ErrorAction SilentlyContinue
       if ($files) {
           foreach ($file in $files) {
               try {
                   # Log the file found
                   Log-Entry "File found: $($file.FullName)"
                   # Delete the file
                   Remove-Item -Path $file.FullName -Force
                   # Log the file deletion
                   Log-Entry "File deleted: $($file.FullName)"
               } catch {
                   # Log any errors during deletion
                   Log-Entry "Error deleting file: $($file.FullName) - $_"
               }
           }
       }
   }
}
# Roll the logs if necessary
Roll-Logs -logDir $logDirectory -logFileName "ChromeSetup_scan_log.log"
# Call the search and delete function
Search-And-DeleteFile -rootDir $rootDirectory -excludedDirs $excludedDirectories -fileName $fileToFind