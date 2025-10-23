$workingPath = "C:\CHOA\New Folder"
$searchValue = "Hostname:",
"Remediated", 
"Repaired"
#"Missing or faulty driver"

function Get-LogContent {
   param (
       [string]$filepath,
       [string]$searchString
   )

    # Define the file path and the string to search for
    #$filePath = "C:\CHOA\New Folder\CHOA-HPD01630QX.log"
    #$searchString = "Remediated"
    # Read the file line by line and search for the string
    Get-Content $filePath | ForEach-Object {
       if ($_ -match $searchString) {
           # Output the line if the string is found
           $_
       }
    }
}

$files = Get-Childitem $workingPath
foreach ($file in $files) {
    foreach ($value in $searchValue) {
        Get-LogContent -filepath ($file.FullName) -searchString $value
    }
}


#############################################################################



# Define the file path and the string to search for
$filePath = "C:\CHOA\New folder\CHOA-SSO2100RER.log"
$searchString = "Remediated"
# Initialize a counter for the matches
$matchCount = 0
# Read the file line by line and search for the string
Get-Content $filePath | ForEach-Object {
   if ($_ -match $searchString) {
       # Increment the match counter if the string is found
       $matchCount++
   }
}
# Output the details in a table format
$results = [PSCustomObject]@{
   "Log File"       = $filePath
   "Search String"  = $searchString
   "Match Count"    = $matchCount
}
# Display the results in a table
$results | Format-Table -AutoSize


####################################################################################


function Search-Logs {
   param (
       [string]$directoryPath,    # Directory containing the log files
       [string[]]$searchStrings   # Array of search strings
   )
   # Ensure the directory exists
   if (-Not (Test-Path $directoryPath)) {
       Write-Host "Directory not found: $directoryPath" -ForegroundColor Red
       return
   }
   # Initialize a list to hold all results
   $results = @()
   # Iterate through each log file in the directory
   Get-ChildItem -Path $directoryPath -Filter *.log | ForEach-Object {
       $filePath = $_.FullName
       # Read the file and search for each string
       $fileContent = Get-Content $filePath
       foreach ($searchString in $searchStrings) {
           # Initialize a counter for each search string
           $matchCount = 0
           # Search for the string and collect matching lines
           $fileContent | ForEach-Object {
               if ($_ -match $searchString) {
                   # Increment the match counter
                   $matchCount++
                   # Add the matching line details to the results array
                   $results += [PSCustomObject]@{
                       "Log File"       = $filePath
                       "Search String"  = $searchString
                       "Match Count"    = $matchCount
                       "Matched Line"   = $_
                   }
               }
           }
       }
   }
   # Display the results in a table format
   if ($results.Count -gt 0) {
       $results | Format-Table -AutoSize
   } else {
       Write-Host "No matches found" -ForegroundColor Yellow
   }
}
# Example usage:
# Define the directory path and search strings
$directoryPath = "C:\CHOA\New Folder"
$searchStrings = @("Remediated", "Repaired", "Missing")
# Call the function
Search-Logs -directoryPath $directoryPath -searchStrings $searchStrings








<#


<--- ConfigMgr Client Health Check starting --->
Hostname: CHOA-HPD01630QX
Operatingsystem: Microsoft Windows 11 Enterprise
Architecture: 64-Bit
Build: 22621.1.amd64fre.ni_release.220506-1250
Model: HP ProDesk 600 G5 SFF
InstallDate: 2023-07-20 15:10:16
OSUpdates: 2024-09-18 00:00:00
LastLoggedOnUser: CHOA\130196
ClientVersion: 5.00.9128.1007
PSVersion: 5.1
PSBuild: 22621
Sitecode: P01
Domain: CHOA.ORG
MaxLogSize: 4096
MaxLogHistory: 1
CacheSize: 20480
Certificate: 
ProvisioningMode: OK
DNS: OK
PendingReboot: OK
LastBootTime: 2024-09-24 19:37:48
OSDiskFreeSpace: 8.16
Services: Started
AdminShare: OK
StateMessages: OK
WUAHandler: OK
WMI: OK
RefreshComplianceState: 2024-09-25 08:25:52
ClientInstalled: 
Version: 0.8.3
Timestamp: 2024-09-25 08:25:50
HWInventory: 2024-09-24 11:50:25
SWMetering: OK
BITS: Remediated
ClientSettings: 
PatchLevel: 1992
ClientInstalledReason: 



#>