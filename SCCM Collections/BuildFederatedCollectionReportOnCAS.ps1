<#
Script Name: BuildFederatedCollectionReportOnCAS.ps1
Script Version: 1.0
Author: Adam Eaddy
Date Created: 03/24/2021
Description: This script will run on the SCCM CAS and connect to the SQL server to get a listing of all SCCM directories containing the string "!NBCU Federated".  
             Then the script will query WMI on the CAS to get the collections found in the folders listed in the SQL export.  Finally the CSV export will be copied to a UNC share.
Changes:
/#>

#Begin declarations
$CSVPATH = $env:TEMP
$CSVNAME = "FederatedCollections.csv"
$FULLCSVPATH = "$CSVPATH\$CSVNAME"
$REPORTPATH =  "\\wtelab-sb10\Sandbox\FederatedCollectionReport"
$query='select distinct Folderpath from vsms_folders where Folderpath like ''%!NBCU Federated%'''
$FullPathTest = $null

#Load PS Modules
import-module SQLServer

#Get Federated folder list from SQL
$PATHS = Invoke-Sqlcmd -ServerInstance aoadbwp00132\p0088es01 -Database CM_CAS -Query $query

#Check for CSV in %TEMP% and remove if exist
$PATHTEST = test-path $FULLCSVPATH
if ($PATHTEST -eq $true) {Remove-Item -Path $FULLCSVPATH}

#Build Colelction CSV from folder list and write to %TEMP%
foreach ($PATH in $PATHS) {
    
    $fullpath = $PATH.Folderpath
    
    $CollObjs = Get-WmiObject -Namespace ROOT\SMS\site_cas -Class SMS_Collection -Filter "ObjectPath = '$fullpath'" 

    if ($fullpath -ne $FullPathTest) {
        Write-Output "folder,$fullpath" | out-file $FULLCSVPATH -Append -NoClobber -Force
    }

    foreach ($CollObj in $CollObjs) {

        $CollName = $CollObj.Name
        $CollPath = $CollObj.ObjectPath
        if ($CollPath -eq $fullpath) {$MATCH = "TRUE"}
            Write-Output "collection,$CollName" | out-file $FULLCSVPATH -Append -NoClobber -Force
    }

}

#Copy file to UNC share from %TEMP%
$REPORTPATHEXISTS = test-path $REPORTPATH
if ($REPORTPATHEXISTS -eq $true) {
    Copy-Item -Path $FULLCSVPATH -Destination $REPORTPATH -Force 
}