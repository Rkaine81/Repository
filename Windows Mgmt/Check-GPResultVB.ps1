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

# Get GPResult data and store it in a PSObject
$gpResultData = Get-GPResult

# Output the PSObject for inspection
$gpResultData