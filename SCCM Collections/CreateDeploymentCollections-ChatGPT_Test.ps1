# Function to create a new collection
function New-SccmCollection {
    param (
        [string]$Name,
        [string]$ParentCollectionID
    )

    $collectionRule = "SMS_R_System.ResourceID IN (SELECT ResourceID FROM SMS_FullCollectionMembership WHERE CollectionID = '$ParentCollectionID')"

    $newCollection = New-CMDeviceCollection -Name $Name -LimitingCollectionID $ParentCollectionID
    Set-CMCollectionQueryMembershipRule -CollectionId $newCollection.CollectionID -QueryExpression $collectionRule

    return $newCollection
}

# Prompt for source collection ID and number of computers in each new collection
#$sourceCollectionID = Read-Host "Enter the Source Collection ID"
#$numberOfComputersInEachCollection = Read-Host "Enter the number of computers in each new collection"
$sourceCollectionID = "CAS00063"
$numberOfComputersInEachCollection = 7

# Get all devices from the source collection
$sourceCollection = Get-CMDeviceCollection -CollectionId $sourceCollectionID
$devices = Get-CMDevice -CollectionId $sourceCollectionID

# Shuffle the devices randomly
$randomDevices = $devices | Get-Random -Count $devices.Count

# Calculate the number of new collections needed
$numberOfNewCollections = [Math]::Ceiling($randomDevices.Count / $numberOfComputersInEachCollection)

# Create new collections and distribute devices
for ($i = 1; $i -le $numberOfNewCollections; $i++) {
    $newCollectionName = "RandomDistribution_$i"
    $newCollection = New-SccmCollection -Name $newCollectionName -ParentCollectionID $sourceCollectionID

    # Add random devices to the new collection
    $devicesToAdd = $randomDevices[($i - 1) * $numberOfComputersInEachCollection..(($i * $numberOfComputersInEachCollection) - 1)]
    $devicesToAddIDs = $devicesToAdd.ResourceID
    Add-CMDeviceCollectionDirectMembershipRule -CollectionId $newCollection.CollectionID -ResourceId $devicesToAddIDs
}

Write-Host "Random distribution completed. $numberOfNewCollections new collections have been created."
