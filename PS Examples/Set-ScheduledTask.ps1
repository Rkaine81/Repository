### Create Schedule Task for Run Once Script ###
$taskAction = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument '-NoProfile -executionpolicy bypass -File "\\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\ClientHealth\ConfigMgrClientHealth.ps1" -Config "\\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\ClientHealth\config.xml"'

$delaytSpan = New-TimeSpan -Hours 8
$idletSpan = New-TimeSpan -Hours 2
$taskTrigger = New-ScheduledTaskTrigger -Daily -At 8am -RandomDelay $delaytSpan

$taskSettings = new-scheduledtasksettingsset -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -IdleWaitTimeout $idletSpan

# The name of your scheduled task.
$taskName = "ClientHealth"


# Register the scheduled task

Register-ScheduledTask `
    -TaskName $taskName `
    -Action $taskAction `
    -Trigger $taskTrigger `
    -Settings $taskSettings `
    -User "NT AUTHORITY\SYSTEM" 
