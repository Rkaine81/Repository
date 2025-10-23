
$APPS64 = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |  Select-Object DisplayName, DisplayVersion, Publisher, InstallDate

$APPS32 = Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |  Select-Object DisplayName, DisplayVersion, Publisher, InstallDate

foreach ($App64 in $APPS64) {
    if ($App64.DisplayName -ne $null) {
        Write-Output "$($App64.DisplayName),$($App64.DisplayVersion)" | Out-File C:\temp\WVDInstalledApps.csv -Append -NoClobber -Force
    }
}

foreach ($App32 in $APPS32) {
    if ($App32.DisplayName -ne $null) {
        Write-Output "$($App32.DisplayName),$($App32.DisplayVersion)" | Out-File C:\temp\WVDInstalledApps.csv -Append -NoClobber -Force
    }
}