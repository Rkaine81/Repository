$regPath = "HKLM:\Software\CHOA\Reboot"
$regName = "RebootedForOutlookSchedTask"
$regValue = "True"
$regType = "String"

Function Build-SchedTask {
    $fullUserName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $userName = $fullUserName.TrimStart("CHOA\")    $taskName = "CleanupOutlookPluginDirectories"    $appPath = "C:\CHOA\OutlookFix\Cleanup.exe"    # Create the scheduled task action    $action = New-ScheduledTaskAction -Execute "$appPath"    # Create the scheduled task trigger    $trigger = New-ScheduledTaskTrigger -AtLogOn    $User      = "CHOA\$userName"    $Principal = New-ScheduledTaskPrincipal -UserId $User    # Create the scheduled task    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $Principal}Function Prep-CleanupScript {
    If (!(Test-Path C:\CHOA\OutlookFix\cleanup.exe)) {
        If (!(Test-Path C:\CHOA\OutlookFix)) {
            New-Item -ItemType Directory -Path C:\CHOA -Name OutlookFix -Force
            Copy-item Cleanup.exe C:\CHOA\OutlookFix\Cleanup.exe -Force
        }else{
            Copy-item Cleanup.exe C:\CHOA\OutlookFix\Cleanup.exe -Force
        }
    }
}

Function New-RegKey {
Param(    [Parameter(Mandatory=$true)]    [string]$registryPath,    [Parameter(Mandatory=$true)]    [string]$regName,    [Parameter(Mandatory=$true)]    [string]$regType,    [Parameter(Mandatory=$true)]    [string]$regValue)    If(!(Test-Path $registryPath)){        New-Item -Path $registryPath -Force    }    New-ItemProperty -Path $registryPath -Name $regName -PropertyType $regType -Value $regValue -Force
}


If (!(test-path "C:\CHOA\OutlookFix\cleanup.exe")) {
    Prep-CleanupScript
}

$schedTask = Get-ScheduledTask -TaskName "CleanupOutlookPluginDirectories" -ErrorAction SilentlyContinue
If ($null -eq $schedTask) {
    Build-SchedTask
}

$validate = Get-ScheduledTask -TaskName "CleanupOutlookPluginDirectories" -ErrorAction SilentlyContinue
If (($validate.TaskName) -eq "CleanupOutlookPluginDirectories") {
    New-RegKey $regPath $regName $regType $regValue
}
