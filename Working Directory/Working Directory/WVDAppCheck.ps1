$AppList=@(
@("Vizrt Viz Pilot 8.4.0.24694","8.4.0.24694"),
@("Avid iNEWS","5.6.3.1"))


$APPS64 = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |  Select-Object DisplayName, DisplayVersion, Publisher, InstallDate

$APPS32 = Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |  Select-Object DisplayName, DisplayVersion, Publisher, InstallDate

foreach ($App in $AppList) {
    $AppName = $App[0]
    $AppVer = $App[1]
    
    if (($APPS32).DisplayName -contains "$AppName") {
        Write-Host "The registry contains an entry that matches $AppName."
    }

}


