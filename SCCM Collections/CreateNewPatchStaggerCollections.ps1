 <#
Script Name: CreateDeploymentCollections.ps1
Script Version: 1.0
Author: Adam Eaddy
Contributers: 
Date Created: 13/07/2023
Date Updated: 
Description: The purpose of this script is to create device collections for projects that need randomized, phased deployments.  
             This script will:
             1. Get all device members of the provided collection.  
             2. Randomize that list of devices.
             3. Build the "deployment" collection.
             4. Build the appropriate ammount of "member" collections based on the "group size" value provided. 
             5. Build the collections.
             6. Add the devices into the member collections.
             7. Create a folder and move the collections into the folder located at: DeviceCollection"\Workstation Collections\Targeted Deployments".
             8. Creates a log file and a CSV file in the C:\USGDAT folder with each device and the collection it was added to. 


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
    [string]$nbcuCollectionName,
    [Parameter(Mandatory=$true)]
    [string]$groupSize,
    [Parameter(Mandatory=$true)]
    [string]$sourceCollectionID
)


# Configure and begin Logging
$logPath = "C:\USGDAT"
$logFileName = "$nbcuCollectionName Collection Creation.log"
$csvName = "$nbcuCollectionName Collection Creation.csv"
$fullLogPath = "$logPath\$logFileName"
$fullCsvPath = "$logPath\$csvName"
write-host "Check to see if log directory exists."
If (!(test-path C:\USGDAT)) {
    New-Item -ItemType Directory -Path C:\ -Name USGDAT | Out-Null
    write-host "Created log directory: $logPath." -ForegroundColor Green
    If (!(test-path C:\USGDAT)) {
        write-host "Could not create log directory: $logPath." -ForegroundColor Red  
        Exit 1
    }
}
Try {
$ErrorActionPreference = 'Stop'
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] ### Starting Collection creation process for $nbcuCollectionName. ###" | out-file $fullLogPath -Force -Append -NoClobber
    ### Only write on successful try
}
Catch {
    Write-Host "Failed to Create Log file." -ForegroundColor Red
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Failed to create log file." | Out-File $fullLogPath -Force -Append -NoClobber
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Error Details: $ErrorMessage; Description: $_;" | Out-File $fullLogPath -Force -Append -NoClobber
}
Write-Host "A log file can be found in the following directory: $fullLogPath."


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
    # SCCM Site configuration and connection
    $SiteCode = "CAS" # Site code 
    $ProviderMachineName = "AOAAPWP00375.tfayd.com" # SMS Provider machine name
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
$masterCollection = "# $nbcuCollectionName Deployment Collection"
Write-Host "Creating the master Deployment Collection: $masterCollection"
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Creating the master Deployment Collection: $masterCollection" | out-file $fullLogPath -Force -Append -NoClobber
Try {
$ErrorActionPreference = 'Stop'
    $newDeploymentCol = Get-CMDeviceCollection -Name $masterCollection -ErrorAction SilentlyContinue
    if ($null -eq $newDeploymentCol) {
        New-CMDeviceCollection -Name $masterCollection -LimitingCollectionId CAS0064A -RefreshType None | Out-Null
        Write-Output "Created deployment collection: $masterCollection."
    }
}
Catch {
    Write-Host "Failed to Create Deploymewnt collection." -ForegroundColor Red
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Failed to Create Deploymewnt collection." | Out-File $fullLogPath -Force -Append -NoClobber
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Error Details: $ErrorMessage; Description: $_;" | Out-File $fullLogPath -Force -Append -NoClobber
}

# Adding exclusion collections to master collection. 
Write-Host "Adding exclusions to master collection."
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Adding exclusions to master collection." | out-file $fullLogPath -Force -Append -NoClobber
Try {
$ErrorActionPreference = 'Stop'
    Add-CMDeviceCollectionExcludeMembershipRule -CollectionName $masterCollection -ExcludeCollectionId CAS029FA | Out-Null
    Write-Host "The exclusion collection have been added successfully." -ForegroundColor Green
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] The exclusion collection have been added successfully." | out-file $fullLogPath -Force -Append -NoClobber
}
Catch {
    Write-Host "Failed to add the exclusion collection: $(($exclusionCollection).name). See log file for more details." -ForegroundColor Red
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Failed to add the exclusion collection: $(($exclusionCollection).name). See log file for more details." | Out-File $fullLogPath -Force -Append -NoClobber
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Error Details: $ErrorMessage; Description: $_;" | Out-File $fullLogPath -Force -Append -NoClobber
}

# Building device collection logic. 
# Creating PowerShell object containing device and collection details. 
Write-Host "Beginning the collection creation process."
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Beginning the collection creation process." | out-file $fullLogPath -Force -Append -NoClobber
$startCollNum = 1
$groups = for ($start = 0; $start -lt $randomCorpDevices.Count; $start += $groupSize) {
    $end = [Math]::Min(($start + $groupSize - 1), ($randomCorpDevices.Count - 1))
    $group = $randomCorpDevices[$start..$end]
    $groupNum = [math]::Floor($start / $groupSize)
    $collnum = $startCollNum
    $collNumStr = ($collnum.ToString())
    If ($collNum -eq 1 -or $collnum -eq 2 -or $collnum -eq 3 -or $collnum -eq 4 -or $collnum -eq 5 -or $collnum -eq 6 -or $collnum -eq 7 -or $collnum -eq 8 -or $collnum -eq 9) { 
        $collNumStr = "0$collNumStr"
    } 
    $collName = "$nbcuCollectionName $collNumStr"
    [PSCustomObject]@{
        GroupNumber = [math]::Floor($start / $groupSize) + 1
        Computers = $group
        CollectionName = $collName
    }
    if ($groupNum -ne $collNum) {$startCollNum = $startCollNum+1}
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
            New-CMDeviceCollection -Name $collection -LimitingCollectionId $sourceCollectionID -RefreshType None | Out-Null
            Write-Host "Adding exclusions to collection $collection."
            Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Adding exclusions to collection $collection." | out-file $fullLogPath -Force -Append -NoClobber
            Try {
            $ErrorActionPreference = 'Stop'
                Add-CMDeviceCollectionExcludeMembershipRule -CollectionName $collection -ExcludeCollectionId CAS02A29 | Out-Null
                Write-Host "The exclusion collection have been added successfully." -ForegroundColor Green
                Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] The exclusion collection have been added successfully." | out-file $fullLogPath -Force -Append -NoClobber
            }
            Catch {
                Write-Host "Failed to add the exclusion collection: $(($exclusionCollection).name). See log file for more details." -ForegroundColor Red
                Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Failed to add the exclusion collection: $(($exclusionCollection).name). See log file for more details." | Out-File $fullLogPath -Force -Append -NoClobber
                Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Error Details: $ErrorMessage; Description: $_;" | Out-File $fullLogPath -Force -Append -NoClobber
            }
        }
    }
    Write-Host "Completed creating collections."
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Completed creating collections." | out-file $fullLogPath -Force -Append -NoClobber
}
Catch {
    Write-Host "Failed to create device collection $collection.  See log file for more details." -ForegroundColor Red
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Failed to create device collection $collection.  See log file for more details." | Out-File $fullLogPath -Force -Append -NoClobber
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Error Details: $ErrorMessage; Description: $_;" | Out-File $fullLogPath -Force -Append -NoClobber
}


# Create SCCM Folder Structure and move collections into folder.
Write-Host "Creating collection folder at: DeviceCollection\Workstation Collections\Targeted Deployments\$nbcuCollectionName"
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Creating collection folder at: DeviceCollection\Workstation Collections\Targeted Deployments\$nbcuCollectionName." | out-file $fullLogPath -Force -Append -NoClobber
Try {
$ErrorActionPreference = 'Stop'
    $folder = Get-CMFolder -Name $nbcuCollectionName
    if ($null -eq $folder) {
        New-CMFolder -ParentFolderPath "DeviceCollection\Workstation Collections\Targeted Deployments" -Name $nbcuCollectionName | Out-Null
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
    #$collsToMove = Get-CMDeviceCollection -Name "*$nbcuCollectionName*"
    $masterCollObj = Get-CMCollection -Name $masterCollection
    Move-CMObject -InputObject $masterCollObj -FolderPath "DeviceCollection\Workstation Collections\Targeted Deployments\$nbcuCollectionName" | Out-Null
    Write-Host "Moving collection $masterCollection into folder at DeviceCollection\Workstation Collections\Targeted Deployments\$nbcuCollectionName."
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Moving collections $masterCollection into folder at DeviceCollection\Workstation Collections\Targeted Deployments\$nbcuCollectionName." | out-file $fullLogPath -Force -Append -NoClobber
    foreach ($group1 in $groups) {
        foreach ($collection1 in $group1.CollectionName) {
            $collToMove = Get-CMCollection -Name $collection1
            Move-CMObject -InputObject  $collToMove -FolderPath "DeviceCollection\Workstation Collections\Targeted Deployments\$nbcuCollectionName" | Out-Null
            Write-Host "Moving collections $(($collToMove).name) into folder at DeviceCollection\Workstation Collections\Targeted Deployments\$nbcuCollectionName."
            Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')] Moving collections $(($collToMove).name) into folder at DeviceCollection\Workstation Collections\Targeted Deployments\$nbcuCollectionName." | out-file $fullLogPath -Force -Append -NoClobber
        }
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