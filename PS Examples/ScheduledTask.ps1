$ErrorActionPreference = 'SilentlyContinue'
if ($null -ne (Get-ScheduledTask -TaskName AppCrashCounter)) {
    if ((Get-ScheduledTask -TaskName AppCrashCounter).State -eq "Ready") {
        return $true
    }else{
        return $false
    }
}else{
    return $false        
}



if ($null -eq (Get-ScheduledTask -TaskName AppCrashCounter)) {

    $taskAction = New-ScheduledTaskAction `
        -Execute 'powershell.exe' `
        -Argument '-NoProfile -executionpolicy bypass -File "C:\Apps\Dex\HourlyAppCreashMetricsRegistry.ps1"'

    $idletSpan = New-TimeSpan -Hours 1
    $taskSettings = new-scheduledtasksettingsset -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -IdleWaitTimeout $idletSpan -ExecutionTimeLimit $idletSpan

    $taskName = "AppCrashCounter"
    $xx = Get-Random 50
    $t1 = New-ScheduledTaskTrigger -Daily -At 00:$xx
    $t2 = New-ScheduledTaskTrigger -Once -At 00:$xx `
            -RepetitionInterval (New-TimeSpan -Hour 1) `
            -RepetitionDuration (New-TimeSpan -Hours 24) `
            -RandomDelay (New-TimeSpan -Minutes 50) `
            
    $t1.Repetition = $t2.Repetition

    Register-ScheduledTask `
        -TaskName $taskName `
        -Action $taskAction `
        -Trigger $t1 `
        -Settings $taskSettings `
        -User "NT AUTHORITY\SYSTEM" 

}else{

    if ((Get-ScheduledTask -TaskName $taskName).State -ne "Ready") {
        Enable-ScheduledTask -TaskName $taskName
    }
}
