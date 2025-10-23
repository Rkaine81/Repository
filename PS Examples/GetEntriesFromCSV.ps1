#Script Name: GetEntriesFromCSV.ps1
#Script Version: 1.0
#Author: Adam Eaddy
#Date Created: 03/11/2021
#Description: This script will return the values of a single column CSV file.
#Changes:

#Define Logging
$DATE = Get-Date
$SDATE = get-date -Format MMddyyyy
$LOGPATH = "C:\temp\Exclusions"
#Set Log name
$LOGFILE = "ExclusionsEntriesFromCSV_$SDATE.log"
$FULLLOGPATH = "$LOGPATH\$LOGFILE"
$CSVFILE = "ExclusionsEntriesFromCSV_$SDATE.csv"
$FULLCSVPATH = "$LOGPATH\$CSVFILE"

$CSVFILE = "D:\Users\206676599\OneDrive - NBCUniversal\Scripts\script reference\Collection and Machine retrival.csv"


Write-Output "---Begin listing the entries of the CSV file. - $DATE---" | Out-File $FULLLOGPATH -Append -Force -NoClobber

$DATALIST = Import-Csv -Path $CSVFILE -Header Collection,Computer

foreach ($DATA in $DATALIST) {
    if ($DATA.Collection -like "*Exclusions:*") {
        Write-Output "$($DATA.Collection),$($DATA.Computer)" | Out-File $FULLCSVPATH -Append -Force -NoClobber
    }
}

Write-Output "---Completed listing the entries of the CSV file. - $DATE---" | Out-File $FULLLOGPATH -Append -Force -NoClobber