$exePath = "C:\ProgramFiles\Google\Chrome\Application\107.0.5304.107\chrome.dll"
$targetVersion = "107.0.5304.107"

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


if (Test-Path $exePath) {
    $versionInfo = Get-FileVersionInfo $exePath
    $actualVersion = $versionInfo.ProductVersion

    if ($actualVersion -eq $targetVersion) {
        Write-Output "$targetVersion"
    } else {
        Write-Output "$actualVersion."
    }
} else {
    Write-Output "0"
}