$targetVersion = "4.33.90.0"
$fullFilePath = ".\Files\slack-standalone-4.33.90.0.msi"

function Get-FileVersionInfo {
    param (
        [string]$FilePath
    )

    $fileInfo = New-Object System.IO.FileInfo $FilePath
    $versionInfo = $null

    if ($fileInfo.Exists) {
        try {
            $versionInfo = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($fileInfo.FullName)
        } catch {
            Write-Output "Failed to get file version information for '$FilePath'."
        }
    } else {
        Write-Output "File not found: '$FilePath'."
    }

    return $versionInfo
}

if (Test-Path $fullFilePath) {
    $versionInfo = Get-FileVersionInfo $fullFilePath
    $actualVersion = $versionInfo.ProductVersion
    
    if ($actualVersion -lt $targetVersion) {
        return $false
    } else {
        return $true
    }
} else {
    return $true
}


