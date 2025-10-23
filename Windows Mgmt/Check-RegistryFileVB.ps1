# Define the path to the reg file
$regFilePath = "C:\Temp\citrix fix\UnBlock.reg"

# Read the content of the reg file
$regFileContent = Get-Content -Path $regFilePath

# Initialize variables
$keysArray = @()
$currentKey = $null
$keyValuePairs = @{}

# Function to check if a registry value exists
function Test-RegistryValue {
    param(
        [string]$fullPath,
        [string]$valueName
    )
    try {
        $key = Get-Item -Path $fullPath
        $key.GetValue($valueName) -ne $null
    } catch {
        $false
    }
}

# Parse reg file content
foreach ($line in $regFileContent) {
    # Trim the line to avoid whitespace issues
    $line = $line.Trim()

    # Check if the line is a registry key header
    if ($line -match "^\[([^\]]+)\]$") {
        # If there is a current key, check its existence
        if ($currentKey) {
            # Check if the registry key exists
            $exists = Test-Path -Path "Registry::\$currentKey"

            # If the key does not exist, store it
            if (-not $exists) {
                $keysArray += [PSCustomObject]@{
                    Key    = $currentKey
                    Values = $keyValuePairs
                }
            } else {
                # Check for missing values within the key
                $missingValues = @{}
                foreach ($kvp in $keyValuePairs.GetEnumerator()) {
                    $valueExists = Test-RegistryValue -fullPath "Registry::\$currentKey" -valueName $kvp.Key

                    if (-not $valueExists) {
                        $missingValues[$kvp.Key] = $kvp.Value
                    }
                }

                # If any values are missing, store them
                if ($missingValues.Count -gt 0) {
                    $keysArray += [PSCustomObject]@{
                        Key    = $currentKey
                        Values = $missingValues
                    }
                }
            }
        }

        # Set the new current key
        $currentKey = $matches[1]
        $keyValuePairs = @{}
    }
    elseif ($line -match '^"([^"]+)"="([^"]*)"$') {
        # Parse key-value pairs
        $keyValuePairs[$matches[1]] = $matches[2]
    }
}

# Check the last key if it exists
if ($currentKey) {
    $exists = Test-Path -Path "Registry::\$currentKey"

    if (-not $exists) {
        $keysArray += [PSCustomObject]@{
            Key    = $currentKey
            Values = $keyValuePairs
        }
    } else {
        # Check for missing values within the key
        $missingValues = @{}
        foreach ($kvp in $keyValuePairs.GetEnumerator()) {
            $valueExists = Test-RegistryValue -fullPath "Registry::\$currentKey" -valueName $kvp.Key

            if (-not $valueExists) {
                $missingValues[$kvp.Key] = $kvp.Value
            }
        }

        # If any values are missing, store them
        if ($missingValues.Count -gt 0) {
            $keysArray += [PSCustomObject]@{
                Key    = $currentKey
                Values = $missingValues
            }
        }
    }
}

# Output the array of missing keys and values
$keysArray
#($keysArray.Values).Keys