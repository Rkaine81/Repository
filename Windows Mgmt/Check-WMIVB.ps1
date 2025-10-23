Function Check-WMIRepo {
    Try {
        $repoCheck = winmgmt /verifyrepository
        If ($repoCheck -ne "WMI repository is consistent") {
            return "Run the WMI Repair"
        }else{
            return "Success"
        }
    } catch {
        return "Run the WMI Repair.  Error verifying WMI repository: $_"
    }
}


Function Check-WindowsWMI {
    try {
        $osInfo = Get-WmiObject -Class Win32_OperatingSystem -ErrorAction Stop
        if ($osInfo) {
            return "Success"
        } else {
            return "Run the WMI Repair"
        }
    } catch {
        return "Run the WMI Repair.  Error querying WMI: $_"
    }
}

Function Check-SCCMWMI {
    try {
        $namespace = "root\ccm"
        $osInfo = Get-WmiObject -Namespace $namespace -Class SMS_Client -ErrorAction Stop
        if ($osInfo) {
            return "Success"
        } else {
            return "Run the WMI Repair"
        }
    } catch {
        return "Run the WMI Repair.  Error querying WMI: $_"
    }
}


# Gather all results into a single PSObject
$WMICheckResults = [PSCustomObject]@{
    RepoCheck = Check-WMIRepo
    WinCheck = Check-WindowsWMI
    CMWMI = Check-SCCMWMI
}

$results = @()
$results += "WMI Repository Test:    $($WMICheckResults.RepoCheck)"
$results += "Windows Query Test:     $($WMICheckResults.WinCheck)"
$results += "SCCM Query Test:        $($WMICheckResults.CMWMI)"

return $results