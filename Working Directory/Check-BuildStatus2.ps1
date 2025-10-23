#Apps to Check for

<#
Configuration Manager Client
Office 365
Teams
Trellix Agent
Trellix Data Loss prevention - endpoint
Trellix Management of Native Encryption
Qualys
Crowdstrike
Cisco Secure Client - AnyConnect VPN
Cisco Secure Client - Umbrella
Cisco Webex
Citrix Workspace
Microsoft Edge
/#>

function Check-Application {
    param (
        [string]$appName
    )
    $installed = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -eq "$appName" }
    if (-not $installed) {
        $installed = Get-ItemProperty HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -eq "$appName" }
    }
    return [bool]$installed
}


Function Check-AppVersion {
    param (
        [string]$appName
    )  
    $installed = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -eq "$appName" }
    if (-not $installed) {
        $installed = Get-ItemProperty HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -eq "$appName" }
    }
    return $installed.DisplayVersion
}


Function Get-VersionMatch {
    param (
        [version]$obj1, 
        [version]$obj2
    ) 
    If ($obj1 -gt $obj2) {
        return "older" 
        #"Versions do not match. Version expected: $obj1. Version reported: $obj2."
    }elseif ($obj1 -eq $obj2) {
        return "match"
    }elseif ($obj1 -lt $obj2) {
        return "newer"
    } 
}

Function logReturn ($result) {
    if ($result.State -eq "Installed") {
        If ($result.Status -eq "match") {
            Write-Host "✅ $($result.Application) $($result.Version)" -ForegroundColor Green
        }elseif ($result.Status -eq "newer") {
            Write-Host "✅ $($result.Application) $($result.Version) - This version is newer than the expected: $($result.ExpectedVer)." -ForegroundColor Green
        }else{
            Write-Host "✅ $($result.Application) $($result.Version) - This version needs to be updated to $($result.ExpectedVer)." -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ $($result.Application)" -ForegroundColor Red
    }
}

# Impoering CSV
$csvFile = "\\choa-cifs\install\CM_P01\00_ToolsTestTemplates\AE\imaging\appList.csv"
$data = Import-Csv -Path $csvFile
# Initialize results array
$results = @()
# Checking applications
$count = 0
$total = $data.Count
foreach ($obj in ($data)) {
    $app = $obj.DisplayName
    $count++
    # Show progress bar
    $progress = [math]::Round(($count / $total) * 100)
    Write-Progress -Activity "Checking for $app..." -Status "$count of $total ($progress%)" -PercentComplete $progress
    # Check if the application is installed
    $isInstalled = Check-Application -appName $app
    $appVersion = Check-AppVersion -appName $app
    $versionMatch = Get-VersionMatch -obj1 ($obj.DisplayVersion) -obj2 $appVersion
    # Store result
    $results += [PSCustomObject]@{
        Application = $app
        State      = if ($isInstalled) { "Installed" } else { "Missing" }
        Version     = $appVersion
        Status      = $versionMatch
        ExpectedVer = $obj.DisplayVersion
    }

}
# Clear progress bar
Write-Progress -Activity "Checking installed applications complete." -Completed
# Display formatted checklist
Write-Host "`nApplication Installation Check:`n"
foreach ($result in $results) {
    logReturn -result $result
}
Write-Host "`nCheck complete!"

#Read-Host "`nPress the Enter key to exit"