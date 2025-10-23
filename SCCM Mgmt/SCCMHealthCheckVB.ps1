$healthCheckResults = @()


# Function to test for SCCM WMI Classes
function Check-SCCMWMI {
    Try {
        $namespace = "ROOT\ccm"
        $wmiResults = Get-WmiObject -Namespace $namespace -Class SMS_Client
        if ($wmiResults) {
            return "Success"
        } else {
            return "Root\ccm not found. Run the SCCM Repair."
        }
    }
    Catch {
        return "Failed"
    }
}

# Function to check if a service is running
function Check-ServiceRunning($serviceName) {
    try {
        $service = Get-Service -Name $serviceName -ErrorAction Stop
        if ($service.Status -eq 'Running') {
            return "Success"
        } else {
            return "Service Stopped. Run the SCCM Repair. "
        }
    } catch {
        return "Failed.  Run the SCCM Repair."
    }
}

# Function to check if a process is running
function Check-ProcessRunning($processName) {
    try {
        $process = Get-Process -Name $processName -ErrorAction Stop
        if ($process) {
            return "Success"
        } else {
            return "Process stopped"
        }
    } catch {
        return "Failed.  Run the SCCM Repair."
    }
}

# Function to check for the existence of the SCCM cache
function Check-Cache() {
    $cacheResults = @()
    $namespace = "ROOT\ccm\SoftMgmtAgent"
    $cache = Get-WmiObject -Namespace $namespace -Class CacheConfig
    if ($cache) {
        $cacheSize = $cache.Size / 1024
        $cachePath = $cache.Location

        if (Test-Path $cachePath) {
            [INT]$usedCache = (Get-ChildItem $cachePath -force -Recurse -ErrorAction SilentlyContinue | Measure-Object Length -sum).sum / 1Gb
            If ($usedCache -gt 15) {
                $clearCache = "The cache is almost full.  Please clear the cache."
            }else{
            
                $clearCache = "Success"
            }
        }
        return $clearCache
    } else {
        return "Failed.  Run the SCCM Repair."
    }
}

# Function to check for the existence of installation files
function Check-InstallationFiles() {
    $installPath = "C:\Windows\CCMSetup"
    if (Test-Path $installPath) {
        return "Success"
    } else {
        return "Failed"
    }
}

# Function to check for the existence of registry keys
function Check-RegistryKeys() {
    $regKeys = @(
        "HKLM:\Software\Microsoft\CCM",
        "HKLM:\Software\Microsoft\CCM\Logging",
        "HKLM:\Software\Microsoft\CCM\LocationServices",
        "HKLM:\Software\Microsoft\CCM\StateSystem"
    )
    
    $missingKeys = @()
    foreach ($key in $regKeys) {
        if (-not (Test-Path $key)) {
            $missingKeys += $key
        }
    }
    
    if ($missingKeys.Count -eq 0) {
        return "Success"
    } else {
        return "Failed"
    }
}

# Function to check communication with the Management Point
function Check-ManagementPointCommunication() {


    try {

        $cert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {
            $_.Extensions | Where-Object {
                $_.Oid.FriendlyName -eq "Certificate Template Information" -and
                $_.Format(0) -match "CHOA Computer"
            }
        }

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        $mpListLocation = ((Get-WmiObject -Namespace "root\ccm" -Class "SMS_LookupMP" -ErrorAction SilentlyContinue).Name).split(".")[0]
        #$mpListLocation = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\CCM\LocationServices" -Name "ManagementPoint" -ErrorAction SilentlyContinue).ManagementPoint
        if ($mpListLocation) {
            $mpUrl = "https://$mpListLocation/SMS_MP/.sms_aut?mplist"
            $response = Invoke-WebRequest -Uri $mpUrl -Certificate $cert
            if ($response.StatusCode -eq 200) {
                return "Success"
            } else {
                return "Failed"
            }
        } else {
            return "Failed"
        }
    } catch {
        return "Failed"
    }
}

# Gather all results into a single PSObject
$healthCheckResults = [PSCustomObject]@{
    SMSAgentHostService           = Check-ServiceRunning "CcmExec"
    ConfigurationManagerClientProcess = Check-ProcessRunning "ccmexec"
    CMWMI                         = Check-SCCMWMI
    CacheCheck                    = Check-Cache
    InstallationFiles             = Check-InstallationFiles
    RegistryKeys                  = Check-RegistryKeys
    ManagementPointCommunication  = Check-ManagementPointCommunication
}

$results = @()
$results += "Agent Service Test:             $($healthCheckResults.SMSAgentHostService)"
$results += "Agent Process Test:            $($healthCheckResults.ConfigurationManagerClientProcess)"
$results += "WMI Test:                 $($healthCheckResults.CMWMI)"
$results += "Installation File Tests:         $($healthCheckResults.InstallationFiles)"
$results += "Cache Test:                         $($healthCheckResults.CacheCheck)"
$results += "Registry Key Test:               $($healthCheckResults.RegistryKeys)"
$results += "Management Point Test:   $($healthCheckResults.ManagementPointCommunication)"

return $results

