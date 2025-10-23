function Get-BitLockerStatus {
    try {
        # Run the manage-bde command and capture the output
        $output = manage-bde -status 2>&1

        # Check if the command executed successfully
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to execute 'manage-bde -status'. Error: $output"
        }

        # Check if the output is empty
        if (-not $output) {
            throw "No output received from 'BitLocker'."
        }

        # Create a custom object to store the data
        $bitLockerStatus = [PSCustomObject]@{
            Volume              = $null
            Size                = $null
            BitLockerVersion    = $null
            ConversionStatus    = $null
            PercentageEncrypted = $null
            EncryptionMethod    = $null
            ProtectionStatus    = $null
            LockStatus          = $null
            IdentificationField = $null
            KeyProtectors       = @()
        }

        # Parse the output line by line
        $keyProtectorsNext = $false
        foreach ($line in $output) {
            if ($line -match 'Volume (\S+): \[(\S+)\]') {
                $bitLockerStatus.Volume = $matches[1]
            }
            elseif ($line -match 'Size:\s+([\d\.]+ \w+)') {
                $bitLockerStatus.Size = $matches[1]
            }
            elseif ($line -match 'BitLocker Version:\s+([\d\.]+)') {
                $bitLockerStatus.BitLockerVersion = $matches[1]
            }
            elseif ($line -match 'Conversion Status:\s+(.+)') {
                $bitLockerStatus.ConversionStatus = $matches[1].Trim()
            }
            elseif ($line -match 'Percentage Encrypted:\s+([\d\.]+)%') {
                $bitLockerStatus.PercentageEncrypted = $matches[1]
            }
            elseif ($line -match 'Encryption Method:\s+(.+)') {
                $bitLockerStatus.EncryptionMethod = $matches[1].Trim()
            }
            elseif ($line -match 'Protection Status:\s+(.+)') {
                $bitLockerStatus.ProtectionStatus = $matches[1].Trim()
            }
            elseif ($line -match 'Lock Status:\s+(.+)') {
                $bitLockerStatus.LockStatus = $matches[1].Trim()
            }
            elseif ($line -match 'Identification Field:\s+(.+)') {
                $bitLockerStatus.IdentificationField = $matches[1].Trim()
            }
            elseif ($line -match 'Key Protectors:') {
                $keyProtectorsNext = $true
            }
            elseif ($keyProtectorsNext -and $line -match '\s+(.+)') {
                $bitLockerStatus.KeyProtectors += $matches[1].Trim()
            }
        }

        # Validate that essential fields were found
        if (-not $bitLockerStatus.Volume) {
            throw "Volume information not found."
        }

        return $bitLockerStatus
    }
    catch {
        Write-Error $_.Exception.Message
    }
}

# Call the function and store the result
$bitLockerInfo = Get-BitLockerStatus

$results = @()
$results += "Volume: $($bitLockerInfo.Volume)"
$results += "Size: $($bitLockerInfo.Size)"
$results += "BitLockerVersion: $($bitLockerInfo.BitLockerVersion)"
$results += "ConversionStatus: $($bitLockerInfo.ConversionStatus)"
$results += "PercentageEncrypted: $($bitLockerInfo.PercentageEncrypted)"
$results += "EncryptionMethod: $($bitLockerInfo.EncryptionMethod)"
$results += "ProtectionStatus: $($bitLockerInfo.ProtectionStatus)"
$results += "LockStatus: $($bitLockerInfo.LockStatus)"
$results += "IdentificationField: $($bitLockerInfo.IdentificationField)"
#$results += "KeyProtectors: ($($bitLockerInfo.KeyProtectors))"

$keyProtectors = $bitLockerInfo.KeyProtectors -join ', '
$results += "KeyProtectors: ($keyProtectors)"

return $results
