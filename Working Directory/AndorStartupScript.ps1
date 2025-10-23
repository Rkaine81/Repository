#=============================== APP RESTART ===============================
# setup scheduled task to restart Andor app in "andor" user context (to show on the TV)
$taskName = "StartAndor"
$appPath = "C:\Andor Health\Rounding Device\Rounding.WPF.exe"
$triggerTime = (Get-Date).AddMinutes(1) # Start the app in 1 minute

# Create the scheduled task action
$action = New-ScheduledTaskAction -Execute "$appPath"

# Create the scheduled task trigger
$trigger = New-ScheduledTaskTrigger -Once -At $triggerTime

$User      = "$env:computername\andor"
$Principal = New-ScheduledTaskPrincipal -UserId $User

# Create the scheduled task
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $Principal

# Start the scheduled task
Start-ScheduledTask -TaskName $taskName

# Delay before scheduled task deletion
Start-Sleep -Seconds 70

# Delete temporary scheduled task
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false

New-Item -Path C:\CHOA -Name "AndorStartUp.tag" -Force

start-sleep 5

If (Get-Process -Name "Rounding.WPF") { Get-Process -Name "Rounding.WPF" | Stop-Process -Force -PassThru }

Start-Sleep 5

$taskName = "StartAndor"
$appPath = "C:\Andor Health\Rounding Device\Rounding.WPF.exe"
$triggerTime = (Get-Date).AddMinutes(1) # Start the app in 1 minute

# Create the scheduled task action
$action = New-ScheduledTaskAction -Execute "$appPath"

# Create the scheduled task trigger
$trigger = New-ScheduledTaskTrigger -Once -At $triggerTime

$User      = "$env:computername\andor"
$Principal = New-ScheduledTaskPrincipal -UserId $User

# Create the scheduled task
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $Principal

# Start the scheduled task
Start-ScheduledTask -TaskName $taskName

# Delay before scheduled task deletion
Start-Sleep -Seconds 70

# Delete temporary scheduled task
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false

New-Item -Path C:\CHOA -Name "AndorStartUp2.tag" -Force