<#
Script Name: UpdateCHOACollectionSubnetQueries.ps1
Script Version: 1.0
Author: Adam Eaddy
Date Created: 03/27/2024
Description: This script will add a subnet query to the CHOA Location by Subnet collections. 
You must provide a csv file in the following format with NO headers.
CSV Example:  Subnet,Full Name,Shortname (Do not include headers in CSV.  This is an example only.)
              10.10,Egleston Floor 1,ECH-1
              10.11,Egleston Floor 2,ECH-2

Script Run Example: .\UpdateCHOACollectionSubnetQueries.ps1 -CSVFILE "C:\Users\179944\OneDrive - CHOA\scripts\working directory\CHOA_Location_Collection_Updater.csv"

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

# Define Limiting Collection
$limitingCollID = "P010028E"
$folderPath = "DeviceCollection\Workstations"
$folderName = "Locations by Subnet"


Write-Host "Beginning Collection Creation." -ForegroundColor Green
write-log "Beginning Collection Creation."
foreach ($obj in $DATALIST) {

    $collection = ($obj.name)
    $comment = ($obj.comment)
    $colExists = $null
    $colExists = Get-CMDeviceCollection -Name $collection
    $subnet = $obj.subnet
    Write-Host "---Beginning Collection Creation for $collection.---" -ForegroundColor Green
    write-log "---Beginning Collection Creation for $collection.---"


    Write-Host "Setting query for $subnet." -ForegroundColor Green
    write-log "Setting query for $subnet."
    $collectionRule = "select SMS_R_System.ResourceID from SMS_R_System where SMS_R_System.IPSubnets like ""$subnet.%"""
    write-host "Query is set to: $collectionRule." -ForegroundColor Green
    Write-Log "Query is set to: $collectionRule."

    if ($null -eq $colExists){

        write-host "Creating Collection $collection." -ForegroundColor Green
        Write-Log "Creating Collection $collection."
        $newCollection = New-CMDeviceCollection -Name $collection -LimitingCollectionId $limitingCollID -RefreshType Periodic -Comment $comment

        #$objToMove = Get-CMCollection -Name $collection
        $collID = ($newCollection.CollectionID)
        
        #Checking if query already exists
        write-host "Checking to see if query exists." -ForegroundColor Green
        Write-Log "Checking to see if query exists."
        $qCheck = $null
        $qCheck = Get-CMDeviceCollectionQueryMembershipRule -CollectionId $collID -RuleName $subnet

        if (!($null -eq $qCheck)) {
            write-host "A query for the subnet $subnet already exists." -ForegroundColor Yellow
            Write-Log "A query for the subnet $subnet already exists."           

        }else{

            write-host "Adding query to collection." -ForegroundColor Green
            Write-Log "Adding query to collection."
            Add-CMDeviceCollectionQueryMembershipRule -CollectionId $collID -QueryExpression $collectionRule -RuleName $subnet

        }
        
        write-host "Moving Collection to $folderPath\$folderName." -ForegroundColor Green
        Write-Log "Moving Collection to $folderPath\$folderName."
        Move-CMObject -InputObject $newCollection -FolderPath "$folderPath\$folderName"
        
    }else{

        Write-Host "Collection $collection already exists." -ForegroundColor Yellow
        write-log "Collection $collection already exists."

        Write-Host "Getting existing collection and adding query." -ForegroundColor Green
        write-log "Getting existing collection and adding query."
        $existingCollection = Get-CMCollection -Name $collection
        $collID = ($existingCollection.CollectionID)
        
        #Checking if query already exists
        write-host "Checking to see if query exists." -ForegroundColor Green
        Write-Log "Checking to see if query exists."
        $qCheck = $null
        $qCheck = Get-CMDeviceCollectionQueryMembershipRule -CollectionId $collID -RuleName $subnet

        if (!($null -eq $qCheck)) {
            write-host "A query for the subnet $subnet already exists." -ForegroundColor Yellow
            Write-Log "A query for the subnet $subnet already exists."           

        }else{

            write-host "Adding query to collection." -ForegroundColor Green
            Write-Log "Adding query to collection."
            Add-CMDeviceCollectionQueryMembershipRule -CollectionId $collID -QueryExpression $collectionRule -RuleName $subnet

        }

    }

        Write-Host "Finished $subnet successfully." -ForegroundColor Green
        write-log "Finished $subnet successfully."

}