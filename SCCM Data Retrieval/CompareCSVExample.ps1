<#
Script Name: GetNBCURegKeysForGPO.ps1
Script Version: 1.0
Author: Adam Eaddy
Date Created: 04/07/2021
Description: This script will search through a Microsoft provided document to get thh registry keys related to the NBCU GPO Settings.
Changes: 
/#>


#Define Logging
$DATE = Get-Date
$SDATE = get-date -Format MMddyyyy
$LOGPATH = "C:\temp"
#Set Log name
$LOGFILE = "GetNBCURegKeysForGPO.csv"
$FULLLOGPATH = "$LOGPATH\$LOGFILE"


$SOURCE = "D:\Users\206676599\OneDrive - NBCUniversal\Scripts\working\WVDSettings\MSSource.csv"
$NBCUGPO = "D:\Users\206676599\OneDrive - NBCUniversal\Scripts\working\WVDSettings\NBCUSettings.csv"


Write-Output "---Begin comparing CSV files. - $DATE---" #| Out-File $FULLLOGPATH -Append -Force -NoClobber

$UserData = Import-Csv -Path $SOURCE
$UserList = Import-Csv -Path $NBCUGPO

$UserOutput = @()

    ForEach ($name in $UserList)
    {

        $userMatch = $UserData | where {$_.PolicySettingName -eq $name.ComputerConfiguration}
        If($userMatch)
        {
            # Process the data

            $UserOutput += New-Object PsObject -Property @{UserName =$name.ComputerConfiguration;column1 =$userMatch.PolicyPath;column2 =$userMatch.RegistryInformation}
        }
        else
        {
        $UserOutput += New-Object PsObject -Property @{UserName =$name.ComputerConfiguration;column1 ="NA";column2 ="NA"}
        }
    }
#$UserOutput | ft
foreach ($obj in $UserOutput) {
    Write-Output "$($obj.UserName),$($obj.column1),$($obj.column2)"| Out-File $FULLLOGPATH -Append -Force -NoClobber
}


Write-Output "---Completed writeing the new CSV file. - $DATE---" #| Out-File $FULLLOGPATH -Append -Force -NoClobber