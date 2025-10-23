
Function Check-Task {
    Get-ScheduledTask -TaskName "CleanupOutlookPluginDirectories"
}

$sTask = Check-Task
If ($null -ne $sTask) {
    Unregister-ScheduledTask -InputObject $sTask -Confirm:$false
}

if (Test-Path C:\CHOA\OutlookFix\cleanup.exe) {
    Remove-Item C:\CHOA\OutlookFix\cleanup.exe -Force
}

$validate = Check-Task
If ((!(Test-Path C:\CHOA\OutlookFix\cleanup.exe)) -and ($null -eq $validate)) {
    if (Test-path "HKLM:\SOFTWARE\CHOA\Reboot\RebootedForOutlookSchedTask") {
        Remove-Item -Path "HKLM:\SOFTWARE\CHOA\Reboot\RebootedForOutlookSchedTask" -Force
    }
}else{
    exit 1
}