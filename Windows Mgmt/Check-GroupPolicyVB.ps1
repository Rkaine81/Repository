function Test-RegistryPOLHealth {
    param (
        [string]$policyType = "Machine"  # Default to Machine, can be changed to "User"
    )

    # Paths to registry.pol files
    $machineRegistryPolPath = "$ENV:SystemRoot\System32\GroupPolicy\Machine\Registry.pol"
    $userRegistryPolPath = "$ENV:SystemRoot\System32\GroupPolicy\User\Registry.pol"

    # Select the appropriate path based on the policy type
    $registryPolPath = if ($policyType -eq "User") {
        $userRegistryPolPath
    } else {
        $machineRegistryPolPath
    }

    $policyData = @()

    # Check if the registry.pol file exists
    if (!(Test-Path -Path $registryPolPath -PathType Leaf)) {
         return "$policyType registry.pol file does not exist."
    }

    # Check last modification date
    $registryPOL = Get-Item -Path $registryPolPath
    $lastWriteTime = $registryPOL.LastWriteTime
    $today = (Get-Date)
    $tooOld = ($today.AddDays(-30))

    if ($lastWriteTime -le $tooOld) {
        return "$policyType registry.pol file has not been modified in the last 30 days."
    }

    # Check for corruption
    $fileHeader = -Join (Get-Content -Encoding Byte -Path $registryPolPath -TotalCount 4)
    if ($fileHeader -eq 8082101103) {
        return "Healthy"
    } else {
        return "$policyType registry.pol file appears to be corrupted."
    }
}

# Define a function to check Group Policy health

# !!! Create a functio that will do the GPResults /V to get last policy date/time.  Then run gpupdate /force and check the date/time again to make sure it is now. 

# Function to run gpresult and parse the output
function Get-GPResult {
    param (
        [string]$username = $env:USERNAME
    )

    # Run gpresult command and capture the output
    $gpResultOutput = gpresult /v /scope computer /user $username | Out-String

    # Initialize PSObject to store parsed data
    $gpResultObject = [PSCustomObject]@{
        OSConfiguration = $null
        OSVersion = $null
        SiteName = $null
        RoamingProfile = $null
        LocalProfile = $null
        ConnectedOverSlowLink = $null
        LastPolicyApplicationTime = $null
        GroupPolicySource = $null
        DomainName = $null
        DomainType = $null
        GroupPolicySlowLinkThreshold = $null
        
    }

    # Regular expressions to parse the output
    $regex = @{
        OSConfiguration = 'OS Configuration:\s+(.*)'
        OSVersion = 'OS Version:\s+(.*)'
        SiteName = 'Site Name:\s+(.*)'
        RoamingProfile = 'Roaming Profile:\s+(.*)'
        LocalProfile = 'Local Profile:\s+(.*)'
        ConnectedOverSlowLink = 'Connected over a slow link\?:\s+(.*)'
        LastPolicyApplicationTime = 'Last time Group Policy was applied:\s+(.*)'
        GroupPolicySource = 'Group Policy was applied from:\s+(.*)'
        DomainName = 'Domain Name:\s+(.*)'
        DomainType = 'Domain Type:\s+(.*)'
        GroupPolicySlowLinkThreshold = 'Group Policy slow link threshold:\s+(.*)'
    }
    
    # Extract data using regular expressions
    foreach ($key in $regex.Keys) {
        if ($key -eq 'AppliedGPOs' -or $key -eq 'NotAppliedGPOs' -or $key -eq 'SecurityGroups') {
            if ($gpResultOutput -match $regex[$key]) {
                $lines = $matches[2].Trim() -split '\r?\n' | Where-Object { $_ -ne '' }
                $gpResultObject.ComputerSettings."$key" = $lines
            }
        } else {
            if ($gpResultOutput -match $regex[$key]) {
                if ($key -eq 'CN') {
                    $gpResultObject.ComputerSettings.CN = $matches[1].Trim()
                } else {
                    $gpResultObject."$key" = $matches[1].Trim()
                }
            }
        }
    }
    
    return $gpResultObject
}

function Check-GroupPolicyErrors {
    # Check event logs for Group Policy errors
    $eventLogs = Get-EventLog -LogName System -Source "GroupPolicy" -EntryType "Error" -Newest 10 -ErrorAction SilentlyContinue
    if ($eventLogs) {
        return "Recent Group Policy errors found. Review and repair if needed."
    } else {
        return "None"
    }
}

function Check-GPClientService {
    $serviceName = "gpsvc"
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

    if ($null -eq $service) {
        return "Group Policy Client service ($serviceName) not found."
    }

    if ($service.Status -eq "Running") {
        return "Success"
    } else {
        return "Group Policy Client service is not running. Status: $($service.Status)"
    }
}

function Get-AppliedCompGPOs {
    # Run gpresult command and store the output
    $gpResultOutput = gpresult /v /r

    # Initialize an array to store applied GPO names
    $appliedGPOs = @()

    # Define a switch to process the output line by line
    $inGPOSection = $false

    # Iterate over each line of the output
    foreach ($line in $gpResultOutput) {
        # Check if the line indicates the start of the Applied GPOs section
        if ($line -match "Applied Group Policy Objects") {
            $inGPOSection = $true
            continue
        }

        # Check if the line indicates the end of the Applied GPOs section
        if ($inGPOSection -and ($line -match "The following GPOs were not applied")) {
            break
        }

        # If in the GPO section, extract GPO names
        if ($inGPOSection) {
            # Trim the line and check if it's a valid GPO name
            $trimmedLine = $line.Trim()
            if ($trimmedLine -ne "") {
                $appliedGPOs += $trimmedLine
            }
        }
    }

    # Return the list of applied GPOs
    return $appliedGPOs | Select-Object -Skip 1
}

Function Get-AppliedUserGPOs {
    # Run gpresult and capture the output
    $output = & gpresult /v /scope:user

    # Convert the output to an array of lines
    $outputLines = $output -split "`r?`n"

    # Initialize a flag and an array to store applied GPOs
    $appliedGPOsSection = $false
    $gpoList = @()

    # Iterate through each line of the output
    foreach ($line in $outputLines) {
        # Check for the start of the "Applied Group Policy Objects" section
        if ($line -match "Applied Group Policy Objects") {
            $appliedGPOsSection = $true
            continue
        }

        # If in the "Applied Group Policy Objects" section, capture GPO names
        if ($appliedGPOsSection) {
            # If a line is empty or indented (indicating a GPO), add it to the list
            $trimmedLine = $line.Trim()
            if ($trimmedLine -eq "") {
                break
            }
            if ($line -match "^\s{8}") { # Capture lines that are indented (indicating a GPO)
                $gpoList += $trimmedLine
            }
        }
    }

    return $gpoList
}

# Gather all results into a single PSObject
$gpoCheckResults = [PSCustomObject]@{
    mRegPol = Test-RegistryPOLHealth -policyType "Machine"
    uRegPol = Test-RegistryPOLHealth -policyType "User"
    Health = Get-GPResult
    gpErrors = Check-GroupPolicyErrors
    gpService = Check-GPClientService
    compGPOS = Get-AppliedCompGPOs
    userGPOS = Get-AppliedUserGPOs
}

# Create an array to store results
$buildObj = @()

# Add each part of the PSCustomObject to the results array, including Health as an object
$buildObj += [PSCustomObject]@{
    Description = "Service Test"
    Data = $gpoCheckResults.gpService
}

# Directly add the Health object to the array
$buildObj += [PSCustomObject]@{
    Description = "Group Policy Health"
    Data = $gpoCheckResults.Health
}

$buildObj += [PSCustomObject]@{
    Description = "Log Errors"
    Data = $gpoCheckResults.gpErrors
}

$buildObj += [PSCustomObject]@{
    Description = "Computer Registry.pol"
    Data = $gpoCheckResults.mRegPol
}

$buildObj += [PSCustomObject]@{
    Description = "User Registry.pol"
    Data = $gpoCheckResults.uRegPol
}

$buildObj += [PSCustomObject]@{
    Description = "Computer GPOs"
    Data = $gpoCheckResults.compGPOs
}

$buildObj += [PSCustomObject]@{
    Description = "User GPOs"
    Data = $gpoCheckResults.userGPOs
}

$lastPolicyTime = (($buildObj | Where-Object { $_.Description -eq "Group Policy Health"}).Data).LastPolicyApplicationTime
$lastPolicyTime = $lastPolicyTime -replace " at ", " "
$policyDateTime = Get-Date $lastPolicyTime
$currentDate = Get-Date
$policyDiff = $currentDate - $policyDateTime
If ($policyDiff.Days -le 1) {
    $gpoHealth = "Healthy"
}else{
    $gpoHealth = "Unhealthy.  GPO has not processed in $($policyDiff.Days) days."
}

$results = @()
$results += "***Applied Group Policies***`n"
$results += "COMPUTER GPOs:"
$results += "-------------------------------------"
$results += (($buildObj | Where-Object { $_.Description -eq "Computer GPOs" }).Data) + "`n"
$results += "USER GPOs:"
$results += "-------------------------------------"
$results += (($buildObj | Where-Object { $_.Description -eq "User GPOs" }).Data) + "`n"
$results += "`n"
$results += "Scroll up to see the applied GPO's."
$results += "----------------------------------------------------------------"
$results += "GPO Health:              " + $gpoHealth
$results += "Service Test:            " + (($buildObj | Where-Object { $_.Description -eq "Service Test" }).Data)
$results += "Last Policy Appled:      " + (($buildObj | Where-Object { $_.Description -eq "Group Policy Health"}).Data).LastPolicyApplicationTime
$results += "Policy Source:           " + (($buildObj | Where-Object { $_.Description -eq "Group Policy Health"}).Data).GroupPolicySource
$results += "Log Errors:              " + (($buildObj | Where-Object { $_.Description -eq "Log Errors" }).Data)
$results += "Computer Registry.pol:   " + (($buildObj | Where-Object { $_.Description -eq "Computer Registry.pol" }).Data)
$results += "User Registry.pol:       " + (($buildObj | Where-Object { $_.Description -eq "User Registry.pol" }).Data)
$results += "----------------------------------------------------------------" + "`n"


return $results