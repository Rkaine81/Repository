 <#
Script Name: CreateDeploymentCollection.ps1
Script Version: 1.0
Author: Adam Eaddy
Contributers: 
Date Created: 13/07/2023
Date Updated: 
Description: The purpose of this script is to create device collections for projects that need randomized, phased deployments.  
             This script will:
             1. Get all devices of the provided collection.  
             2. Randomize that list of devices.
             3. Build the "deployment" collection.
             4. Build the appropriate ammount of "member" collections based on the "group size" value provided. 
             5. Build the collections.
             6. Add the devices into the member collections.
             7. Create a folder and move the collections into the folder located at: DeviceCollection\Workstation Collections\Targeted Deployments.
             8. Creates a log file in C:\CHOA, and a CSV with each device and the collection it was added to. 


Example: 
Example 1: CreateDeploymentCollections.ps1 -nbcuCollectionName "CHG000001 - New Project" -groupSize 3000 -sourceCollectionID CAS0064A
Example 2: CreateDeploymentCollections.ps1 -nbcuCollectionName "CHG000002 - New Project" -groupSize 50 -sourceCollectionID CAS026B9

Changes:


Collection ID Examples:
    CAS0064A - All Non-Fed workstations
    CAS00063 - WTE
    CAS026B9 - Bui Pilot
 
 /#>

 
Param(
    [Parameter(Mandatory=$true)]
    [string]$choaCollectionName,
    [Parameter(Mandatory=$true)]
    [string]$groupSize,
    [Parameter(Mandatory=$true)]
    [string]$sourceCollectionID
)


# Configure and begin Logging
$logPath = "C:\CHOA"
$logFileName = "$choaCollectionName Collection Creation.log"
$csvName = "$choaCollectionName Collection Creation.csv"
$fullLogPath = "$logPath\$logFileName"
$fullCsvPath = "$logPath\$csvName"
write-host "Check to see if log directory exists."
If (!(test-path $logPath)) {
    New-Item -ItemType Directory -Path C:\ -Name CHOA | Out-Null
    write-host "Created log directory: $logPath." -ForegroundColor Green
}else{
    write-host "The directory already exists: $logPath." -ForegroundColor Red
}

Try {
$ErrorActionPreference = 'Stop'
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] ### Starting Collection creation process for $choaCollectionName. ###" | out-file $fullLogPath -Force -Append -NoClobber
    ### Only write on successful try
    Write-Host "A log file can be found in the following directory: $fullLogPath."
}
Catch {
    Write-Host "Failed to Create Log file." -ForegroundColor Red
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Failed to create log file." | Out-File $fullLogPath -Force -Append -NoClobber
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Error Details: $ErrorMessage; Description: $_;" | Out-File $fullLogPath -Force -Append -NoClobber
}

# Begin SCCM Connection
Write-Host "Begin SCCM Configuration."
Write-Host "Checking for SCCM Console."
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Checking for SCCM console." | out-file $fullLogPath -Force -Append -NoClobber
If (!(test-path -Path $ENV:SMS_ADMIN_UI_PATH)) {
    Write-Host "Could not find SCCM Console.  Please install the SCCM console and try again."
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Could not find SCCM Console.  Please install the SCCM console and try again." | out-file $fullLogPath -Force -Append -NoClobber 
    Exit 1
}
Write-Host "SCCM Console foiund at $ENV:SMS_ADMIN_UI_PATH."
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] SCCM Console found at $ENV:SMS_ADMIN_UI_PATH." | out-file $fullLogPath -Force -Append -NoClobber
Write-Host "Connecting to SCCM PowerShell environment."
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Connecting to SCCM PowerShell environment." | out-file $fullLogPath -Force -Append -NoClobber
Try {
$ErrorActionPreference = 'Stop'
    # Site configuration
    $SiteCode = "P01" 
    $ProviderMachineName = "DCVWP-SCCMAP01.choa.org" 
    $initParams = @{}

        # Import the ConfigurationManager.psd1 module 
    if((Get-Module ConfigurationManager) -eq $null) {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
    }
        # Connect to the site's drive if it is not already present
    if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
        New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
    }
        # Set the current location to be the site code.
        Set-Location "$($SiteCode):\" @initParams
}
Catch {
    Write-Host "Failed to connect to the SCCM site." -ForegroundColor Red
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Failed to connect to the SCCM site." | Out-File $fullLogPath -Force -Append -NoClobber
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Error Details: $ErrorMessage; Description: $_;" | Out-File $fullLogPath -Force -Append -NoClobber
}
Write-Host "Successfully connected to the SCCM site." -ForegroundColor Green
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Successfully connected to the SCCM site." | out-file $fullLogPath -Force -Append -NoClobber
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] SCCM Settings:" | out-file $fullLogPath -Force -Append -NoClobber
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Site Code: $SiteCode" | out-file $fullLogPath -Force -Append -NoClobber
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] SCCM Server: $ProviderMachineName " | out-file $fullLogPath -Force -Append -NoClobber
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] SCCM Console Path: $ENV:SMS_ADMIN_UI_PATH" | out-file $fullLogPath -Force -Append -NoClobber


# Get device list
Try {
$ErrorActionPreference = 'Stop'
    $devCollName = (Get-CMDeviceCollection -CollectionID $sourceCollectionID).Name
    Write-Host "Getting device list from collection: $devCollName, collection ID: $sourceCollectionID."
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Getting device list from collection: $devCollName, collection ID: $sourceCollectionID." | out-file $fullLogPath -Force -Append -NoClobber
    $corpDevices = Get-CMCollectionMember -CollectionId $sourceCollectionID
}
Catch {
    Write-Host "Failed to get device list." -ForegroundColor Red
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Failed to get device list." | Out-File $fullLogPath -Force -Append -NoClobber
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Error Details: $ErrorMessage; Description: $_;" | Out-File $fullLogPath -Force -Append -NoClobber
}

# Randomize device list
Write-Host "Randomizing Device List."
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Randomizing Device List." | out-file $fullLogPath -Force -Append -NoClobber
$randomCorpDevices = $corpDevices | Sort-Object {Get-Random}
$deviceCount = $randomCorpDevices.count
$neededCollCount = [math]::ceiling($deviceCount/$groupsize)
    # Log collection details
Write-Host "Number of collections needed: $neededCollCount"
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Number of collections needed: $neededCollCount." | out-file $fullLogPath -Force -Append -NoClobber
Write-Host "Number of devices to add to collections: $deviceCount."
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Number of devices to add to collections: $deviceCount." | out-file $fullLogPath -Force -Append -NoClobber
Write-Host "Number of devices per collection: $groupsize"
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Number of devices per collection: $groupsize" | out-file $fullLogPath -Force -Append -NoClobber


# Creating Master collection.
$masterCollection = "# $choaCollectionName Deployment Collection"
Write-Output $masterCollection
Write-Host "Creating the master Deployment Collection: $masterCollection"
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Creating the master Deployment Collection: $masterCollection" | out-file $fullLogPath -Force -Append -NoClobber
Try {
$ErrorActionPreference = 'Stop'
    $newDeploymentCol = Get-CMDeviceCollection -Name $masterCollection -ErrorAction SilentlyContinue
    if ($newDeploymentCol -eq $null) {
        New-CMDeviceCollection -Name $masterCollection -LimitingCollectionId P010028E -RefreshType None #| Out-Null
        Write-Output "Created deployment collection: $masterCollection."
    }
    
}
Catch {
    Write-Host "Failed to Create Deploymewnt collection." -ForegroundColor Red
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Failed to Create Deploymewnt collection." | Out-File $fullLogPath -Force -Append -NoClobber
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Error Details: $ErrorMessage; Description: $_;" | Out-File $fullLogPath -Force -Append -NoClobber
}

<#

# Adding exclusion collections to master collection. 
Write-Host "Creating Exclusion list and adding as exclusions to master collection."
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Creating Exclusion list and adding as exclusions to master collection." | out-file $fullLogPath -Force -Append -NoClobber
$num = 1
$exclusionCollections = Get-CMDeviceCollection -Name "Exclusions:*"
Try {
$ErrorActionPreference = 'Stop'
    foreach ($exclusionCollection in $exclusionCollections) {
        Add-CMDeviceCollectionExcludeMembershipRule -CollectionName $masterCollection -ExcludeCollectionId ($exclusionCollection).collectionid | Out-Null
        Write-Host "Added exclusion: $(($exclusionCollection).name): $num of $(($exclusionCollections).count)."
        Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Added exclusion: $(($exclusionCollection).name): $num of $(($exclusionCollections).count)." | out-file $fullLogPath -Force -Append -NoClobber
        $num = $num+1
    }
    Write-Host "The exclusions have been added successfully." -ForegroundColor Green
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] The exclusions have been added successfully." | out-file $fullLogPath -Force -Append -NoClobber
}
Catch {
    Write-Host "Failed to add the exclusion collection: $(($exclusionCollection).name). See log file for more details." -ForegroundColor Red
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Failed to add the exclusion collection: $(($exclusionCollection).name). See log file for more details." | Out-File $fullLogPath -Force -Append -NoClobber
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Error Details: $ErrorMessage; Description: $_;" | Out-File $fullLogPath -Force -Append -NoClobber
}

#>

# Building device collection logic.

### Modified this section.  Have not modified it in production code. ###

Write-Host "Beginning the collection creation process."
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Beginning the collection creation process." | out-file $fullLogPath -Force -Append -NoClobber
$groups = for ($start = 0; $start -lt $randomCorpDevices.Count; $start += $groupSize) {
    $end = [Math]::Min(($start + $groupSize - 1), ($randomCorpDevices.Count - 1))
    $group = $randomCorpDevices[$start..$end]
    $groupNum = [math]::Floor($start / $groupSize)
    $startCollNum = 1
    $collNumStr = ($startCollNum.ToString())
    If ($startCollNum -eq 1 -or $startCollNum -eq 2 -or $startCollNum -eq 3 -or $startCollNum -eq 4 -or $startCollNum -eq 5 -or $startCollNum -eq 6 -or $startCollNum -eq 7 -or $startCollNum -eq 8 -or $startCollNum -eq 9) { 
        $collNumStr = "0$collNumStr"
    } 
    $collName = "$choaCollectionName $collNumStr"
    [PSCustomObject]@{
        GroupNumber = [math]::Floor($start / $groupSize) + 1
        Computers = $group
        CollectionName = $collName
    }
    if ($groupNum -ne $startCollNum) {$startCollNum = $startCollNum+1}
}


# Creating Device Collections
Try {
$ErrorActionPreference = 'Stop'
    foreach ($group in $groups) {
        #Write-Host "Group number: $($group.GroupNumber)"
        #Write-Host "Computer names: $($group.Computers.Name -join ', ')"
        #Write-Host "Collection Name: $($group.CollectionName)"
        foreach ($collection in $group.CollectionName) {
            Write-Host "Creating collection: $collection."
            Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Creating collection: $collection." | out-file $fullLogPath -Force -Append -NoClobber
            New-CMDeviceCollection -Name $collection -LimitingCollectionId P010028E -RefreshType None | Out-Null
        }
    }
}
Catch {
    Write-Host "Failed to create device collection $collection.  See log file for more details." -ForegroundColor Red
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Failed to create device collection $collection.  See log file for more details." | Out-File $fullLogPath -Force -Append -NoClobber
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Error Details: $ErrorMessage; Description: $_;" | Out-File $fullLogPath -Force -Append -NoClobber
}

Write-Host "Completed creating collections."
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Completed creating collections." | out-file $fullLogPath -Force -Append -NoClobber


# Create SCCM Folder Structure and move collections into folder.
Write-Host "Creating collection folder at: DeviceCollection\CM_P01\06_InProduction\Software Distribution\CHOA"
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Creating collection folder at: DeviceCollection\CM_P01\06_InProduction\Software Distribution\CHOA\$choaCollectionName." | out-file $fullLogPath -Force -Append -NoClobber
Try {
$ErrorActionPreference = 'Stop'
    $folder = Get-CMFolder -Name $choaCollectionName
    if ($folder -eq $null) {
        New-CMFolder -ParentFolderPath "DeviceCollection\CM_P01\06_InProduction\Software Distribution\CHOA" -Name $choaCollectionName | Out-Null
    }
}
Catch {
    Write-Host "Failed to create folder.  See log file for more details." -ForegroundColor Red
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Failed to create folder.  See log file for more details." | Out-File $fullLogPath -Force -Append -NoClobber
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Error Details: $ErrorMessage; Description: $_;" | Out-File $fullLogPath -Force -Append -NoClobber
}

Write-Host "Moving collections into folder."
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Moving collections into folder." | out-file $fullLogPath -Force -Append -NoClobber
Try {
$ErrorActionPreference = 'Stop'
    $collsToMove = Get-CMDeviceCollection -Name "*$choaCollectionName*"
    foreach ($collToMove in $collsToMove) {
        Move-CMObject -InputObject $collToMove -FolderPath "DeviceCollection\CM_P01\06_InProduction\Software Distribution\CHOA\$choaCollectionName" | Out-Null
    }
}
Catch {
    Write-Host "Failed to move collections into folders.  See log file for more details." -ForegroundColor Red
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Failed to move collections into folders.  See log file for more details." | Out-File $fullLogPath -Force -Append -NoClobber
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Error Details: $ErrorMessage; Description: $_;" | Out-File $fullLogPath -Force -Append -NoClobber
}


# Adding Devices to collections
Write-Host "Adding devices to collections."
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Adding devices to collections." | out-file $fullLogPath -Force -Append -NoClobber
Write-Host "You can find a full CSV report at: $fullCsvPath."
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] You can find a full CSV report at: $fullCsvPath." | out-file $fullLogPath -Force -Append -NoClobber
foreach ($group in $groups) {
    foreach ($device in $group.Computers) {
        Write-Host "Adding $($device.name) to $($group.CollectionName)"
        Write-Output "$($device.name),$($group.CollectionName)" | out-file $fullCsvPath -Force -Append -NoClobber
        Try {
            Add-CMDeviceCollectionDirectMembershipRule -CollectionName $group.CollectionName -ResourceId ((get-cmdevice -Name ($device.name)).resourceID) -ErrorAction SilentlyContinue | Out-Null
        }
        Catch {
            Write-Host "Failed to add $($device.name) to $($group.CollectionName)." -ForegroundColor Red
            Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Failed to add $($device.name) to $($group.CollectionName)." | Out-File $fullLogPath -Force -Append -NoClobber
            Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Error Details: $ErrorMessage; Description: $_;" | Out-File $fullLogPath -Force -Append -NoClobber
        }
        
    }
}


# End of script
Write-Host "Completed Successfully." -ForegroundColor Green
Write-Host "You can find trhe log file at: $fullLogPath." -ForegroundColor Green
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Completed Successfully." | out-file $fullLogPath -Force -Append -NoClobber

# Get-CMDeviceCollection -Name *CHG00009* | Remove-CMDeviceCollection -Force