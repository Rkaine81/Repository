# Define parameters
param (
   [string]$LogPath,
   [string]$BackupDir
)
# Check if log path exists
if (-not (Test-Path -Path $LogPath)) {
   Write-Host "Log path does not exist."
   exit 1
}
# Check if backup directory exists, if not create it
if (-not (Test-Path -Path $BackupDir)) {
   New-Item -Path $BackupDir -ItemType Directory
}
# Get current date for month and year
$currentMonth = Get-Date -Format "yyyyMM"
# Get all log files except for the current month
$logFiles = Get-ChildItem -Path $LogPath -Filter "*.log" | Where-Object {
   $_.LastWriteTime.ToString("yyyyMM") -ne $currentMonth
}
# Test if log files are found
if ($logFiles.Count -eq 0) {
   Write-Host "No log files found to archive."
   exit 0
}
# Group log files by year and month, compress and move to backup directory
$logFiles | Group-Object { $_.LastWriteTime.ToString("yyyyMM") } | ForEach-Object {
   $yearMonth = $_.Name
   $zipFileName = "$BackupDir\Logs_$yearMonth.zip"
   # Create a temporary directory for zipping
   $tempDir = Join-Path -Path $LogPath -ChildPath "temp_$yearMonth"
   if (-not (Test-Path $tempDir)) {
       New-Item -Path $tempDir -ItemType Directory
   }
   # Move files to the temporary directory for zipping
   $_.Group | ForEach-Object {
       Write-Host "Moving file: $($_.FullName) to temp folder: $tempDir"
       Move-Item -Path $_.FullName -Destination $tempDir
   }
   # Compress files
   Write-Host "Compressing files in $tempDir to $zipFileName"
   [System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $zipFileName)
   # Clean up temporary directory
   Remove-Item -Path $tempDir -Recurse
   Write-Host "Compressed and moved files for $yearMonth to $BackupDir."
}
Write-Host "Operation completed."