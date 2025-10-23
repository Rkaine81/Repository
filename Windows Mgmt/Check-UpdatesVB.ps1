# Function to check Windows Update service status
function Check-WindowsUpdateService {
    $service = Get-Service -Name "wuauserv"
    if ($service.Status -eq 'Running') {
        return "Success"
    } else {
        return "Windows Update service is not running. Current status: $($service.Status)"
    }
}

# Function to check for pending updates
function Check-PendingUpdates {
    $updatesSession = New-Object -ComObject Microsoft.Update.Session
    $updatesSearcher = $updatesSession.CreateUpdateSearcher()
    $searchResult = $updatesSearcher.Search("IsInstalled=0")

    if ($searchResult.Updates.Count -eq 0) {
        return "0"
    } else {
        Return "$($searchResult.Updates.Count)"
    }
}

# Function to check Windows Update log for recent errors
function Check-WindowsUpdateLog {
    $logPath = "C:\Windows\WindowsUpdate.log"
    if (Test-Path $logPath) {
        $errors = Get-Content $logPath | Select-String -Pattern "error", "fail"
        if (!($errors)) {
            return "None"
        } else {
            return "Errors Found.  Repair Windows Update"
        }
    } else {
        return "Windows Update log file not found."
    }
}

function Check-RegistryKeys {
    param (
        [string]$regPathWU = "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate",
        [array]$keysToCheckWU = @("WUServer", "WUStatusServer"),
        [array]$valuesToExpectWU = @("https://DCVWP-SCCMSUP01.choa.org:8531", "https://DCVWP-SCCMSUP01.choa.org:8531"),
        
        [string]$regPathAU = "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU",
        [array]$keysToCheckAU = @("UseWUServer", "NoAutoUpdate", "NoAUShutdownOption"),
        [array]$valuesToExpectAU = @("1", "1", "1")
    )

    function Check-Path($regPath, $keysToCheck, $valuesToExpect, $repairMessage) {
        foreach ($i in 0..($keysToCheck.Count - 1)) {
            $key = $keysToCheck[$i]
            $expectedValue = $valuesToExpect[$i]
            try {
                $actualValue = (Get-ItemProperty -Path $regPath -Name $key -ErrorAction Stop).$key
                if ($actualValue -ne $expectedValue) {
                    Write-Output "Failed: Mismatch detected for $key. Expected '$expectedValue', got '$actualValue'. $repairMessage"
                    return
                }
            } catch {
                Write-Output "Failed: Key $key is missing. $repairMessage"
                return
            }
        }
        Write-Output "Success"
    }

    # Check Windows Update path
    Check-Path -regPath $regPathWU -keysToCheck $keysToCheckWU -valuesToExpect $valuesToExpectWU -repairMessage "Run SCCM Repair"

    # Check AU path
    Check-Path -regPath $regPathAU -keysToCheck $keysToCheckAU -valuesToExpect $valuesToExpectAU -repairMessage "Run Windows Update Repair"
}




# Gather all results into a single PSObject
$WUAUCheckResults = [PSCustomObject]@{
    Pending = Check-PendingUpdates
    Service = Check-WindowsUpdateService
    Log = Check-WindowsUpdateLog
    RegKeys = Check-RegistryKeys
}

$results = @()
$results += "Service Test:            $($WUAUCheckResults.Service)"
$results += "Pending Updates:         $($WUAUCheckResults.Pending)"
$results += "Log Errors:              $($WUAUCheckResults.Log)"
$results += "SCCM Registry Test:      $($WUAUCheckResults.RegKeys[0])"
$results += "Windows Registry Test:   $($WUAUCheckResults.RegKeys[1])"

return $results



