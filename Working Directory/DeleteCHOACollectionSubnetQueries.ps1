<#
Script Name: DeleteCHOACollectionSubnetQueries.ps1
Script Version: 1.0
Author: Adam Eaddy
Date Created: 03/27/2024
Description: This script will Delete a subnet query from the CHOA Location by Subnet collections. 
You must provide a csv file in the following format with NO headers.
CSV Example:  Subnet,Full Name,Shortname (Do not include headers in CSV.  This is an example only.)
              10.10,Egleston Floor 1,ECH-1
              10.11,Egleston Floor 2,ECH-2

Script Run Example: .\DeleteCHOACollectionSubnetQueries.ps1 -CSVFILE "C:\Users\179944\OneDrive - CHOA\scripts\working directory\CHOA_Location_Collection_Updater.csv"

Changes:

/#>

    param(
        [Parameter(Mandatory=$true)]
        [string]$CSVFILE
    )


#Define Variables
$DATE = Get-Date
$SDATE = get-date -Format MMddyyyy
$LOGPATH = "C:\Users\179944\OneDrive - CHOA\scripts\working directory"
#$LOGPATH = "C:\Windows\Logs"
$LOGFILE = "CHOA_Subnet_Collections_Updater$SDATE.log"
$FULLLOGPATH = "$LOGPATH\$LOGFILE"
$NEWCSVFILE = "CHOA_Subnet_Collections_Updater_$SDATE.csv"
$FULLCSVPATH = "$LOGPATH\$NEWCSVFILE"


Function Write-Log {

    param(
        [Parameter(Mandatory=$true)]
        [string]$VALUE
    )


    write-output "$(get-date): $VALUE" | out-file $FULLLOGPATH -Append -Force -NoClobber

}

#This lineis for testing
#$CSVFILE = "C:\Users\179944\OneDrive - CHOA\scripts\working directory\CHOA_Location_Collection_Updater.csv"

Write-Log "Begin listing the entries of the CSV file."
$DATALIST = Import-Csv -Path $CSVFILE -Header subnet,comment,name

# Begin SCCM Connection
Write-Host "Begin SCCM Configuration."
Write-Host "Checking for SCCM Console."
Write-Log "Checking for SCCM console."
If (!(test-path -Path $ENV:SMS_ADMIN_UI_PATH)) {
    Write-Host "Could not find SCCM Console.  Please install the SCCM console and try again."
    write-log "Could not find SCCM Console.  Please install the SCCM console and try again." 
    Exit 1
}
Write-Host "SCCM Console foiund at $ENV:SMS_ADMIN_UI_PATH."
write-log "SCCM Console found at $ENV:SMS_ADMIN_UI_PATH."
Write-Host "Connecting to SCCM PowerShell environment."
write-log "Connecting to SCCM PowerShell environment."
Try {
$ErrorActionPreference = 'Stop'
    # SCCM Site configuration and connection
    $SiteCode = "P01" # Site code 
    $ProviderMachineName = "dcvwp-sccmap01.choa.org" # SMS Provider machine name
    $initParams = @{}
        # Import the ConfigurationManager.psd1 module 
    if($null -eq (Get-Module ConfigurationManager)) {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
    }
        # Connect to the site's drive if it is not already present
    if($null -eq (Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue)) {
        New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
    }
        # Set the current location to be the site code.
        Set-Location "$($SiteCode):\" @initParams
        Write-Host "Successfully connected to the SCCM site." -ForegroundColor Green
        write-log "Successfully connected to the SCCM site."
        write-log "SCCM Settings:"
        write-log "Site Code: $SiteCode"
        write-log "SCCM Server: $ProviderMachineName "
        write-log "SCCM Console Path: $ENV:SMS_ADMIN_UI_PATH"
}
Catch {
    Write-Host "Failed to connect to the SCCM site." -ForegroundColor Red
    write-log "Failed to connect to the SCCM site."
    write-log "Error Details: $ErrorMessage; Description: $_;"
}

Write-Host "Beginning Collection Creation." -ForegroundColor Green
write-log "Beginning Collection Creation."
foreach ($obj in $DATALIST) {

    $collection = ($obj.name)
    $comment = ($obj.comment)
    $colExists = $null
    $colExists = Get-CMDeviceCollection -Name $collection
    $subnet = $obj.subnet

    Write-Host "Getting existing collection and removing query."
    write-log "Getting existing collection and removing query."
    $existingCollection = Get-CMCollection -Name $collection
    $collID = ($existingCollection.CollectionID)
        
    #Checking if query already exists
    write-host "Checking to see if query exists."
    Write-Log "Checking to see if query exists."
    $qCheck = $null
    $qCheck = Get-CMDeviceCollectionQueryMembershipRule -CollectionId $collID -RuleName $subnet

    if (!($null -eq $qCheck)) {
        write-host "A query for the subnet $subnet was found."
        Write-Log "A query for the subnet $subnet was found."
        Remove-CMDeviceCollectionQueryMembershipRule -CollectionId $collID -RuleName $subnet -Force           

    }else{

        write-host "A query for the subnet $subnet was not found." -ForegroundColor Yellow
        Write-Log "A query for the subnet $subnet was not found."
        #Add-CMDeviceCollectionQueryMembershipRule -CollectionId $collID -QueryExpression $collectionRule -RuleName $subnet

        }

 

        Write-Host "Finished removing $subnet successfully." -ForegroundColor Green
        write-log "Finished removing $subnet successfully."

}