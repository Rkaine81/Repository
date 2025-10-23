$fullUserName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$userName = $fullUserName.TrimStart("CHOA\")
$folderPath1 = "C:\Users\$userName\AppData\Local\Microsoft\Office\16.0\Wef"
$folderPath2 = "C:\Users\$userName\AppData\Local\Microsoft\Outlook\HubAppFileCache\*"
$regPath = "HKCU:\Software\CHOA\Reboot"
$regName = "RebootedForOutlook"
$regValue = "True"
$regType = "String"
$regPathMS = "HKCU:\SOFTWARE\Microsoft\Office\16.0\Common\Identity"
$regNameMS = "DisableOneAuth"
$regValueMS = "1"
$regTypeMS = "DWORD"

# Function to delete folder if exists
function Delete-Folder {
Param (
    $folderpath
)
   if (Test-Path $folderPath) {
       Remove-Item -Path $folderPath -Recurse -Force
   }
}

# Function to create registry key
#Create registry path if it doesn't exist. Then modify entry value.  Function WriteRegKey{Function New-RegistryKey {    Param(        [Parameter(Mandatory=$true)]        [string]$registryPath,        [Parameter(Mandatory=$true)]        [string]$regName,        [Parameter(Mandatory=$true)]        [string]$regType,        [Parameter(Mandatory=$true)]        [string]$regValue    )    #Try{        #Get-ItemProperty $registryPath        If(!(Test-Path $registryPath)){            New-Item -Path $registryPath -Force        }        New-ItemProperty -Path $registryPath -Name $regName -PropertyType $regType -Value $regValue -Force | Write-Host    #}        #Catch{AppendLog "$((Get-PSCallStack)[1].Command) Set Registry Value failed: $LASTEXITCODE; Error Details: $($_.ErrorDetails); Error Stack Trace: $($_.ScriptStackTrace); Target Object: $($_.TargetObject); Invocation Info: $($_.InvocationInfo)"}}


Function Build-SchedTask {
    $fullUserName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $userName = $fullUserName.TrimStart("CHOA\")    $taskName = "CleanupOutlookPluginDirectories"    $appPath = "C:\CHOA\OutlookFix\Cleanup.exe"    # Create the scheduled task action    $action = New-ScheduledTaskAction -Execute "$appPath"    # Create the scheduled task trigger    $trigger = New-ScheduledTaskTrigger -AtLogOn    $User      = "CHOA\$userName"    $Principal = New-ScheduledTaskPrincipal -UserId $User    # Create the scheduled task    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $Principal}

Function Prep-CleanupScript {
    If (!(Test-Path C:\CHOA\OutlookFix\cleanup.exe)) {
        If (!(Test-Path C:\CHOA\OutlookFix)) {
            New-Item -ItemType Directory -Path C:\CHOA -Name OutlookFix -Force
            Copy-item Cleanup.exe C:\CHOA\OutlookFix\Cleanup.exe -Force
        }else{
            Copy-item Cleanup.exe C:\CHOA\OutlookFix\Cleanup.exe -Force
        }
    }
}

Add-Type -AssemblyName System.Windows.Forms
$timeoutSeconds = 1800
$defaultAction = 'Now'
$choice = $null
# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Reboot Required in 30 Minutes!"
$form.Size = New-Object System.Drawing.Size(550, 200)
$form.StartPosition = "CenterScreen"
$form.TopMost = $true
$label = New-Object System.Windows.Forms.Label
$label.Text = 'Press "Reboot" to reboot now, or "Wait" to reboot in 30 minutes.'
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(30, 20)
$form.Controls.Add($label)
$btnNow = New-Object System.Windows.Forms.Button
$btnNow.Text = "Reboot"
$btnNow.Location = New-Object System.Drawing.Point(160, 80)
$btnNow.Size = New-Object System.Drawing.Size(100, 30)
$btnNow.Add_Click({
   $global:choice = "Now"
   $timer.Stop()
   $form.Close()
})
$form.Controls.Add($btnNow)
$btnLater = New-Object System.Windows.Forms.Button
$btnLater.Text = "Wait"
$btnLater.Location = New-Object System.Drawing.Point(300, 80)
$btnLater.Size = New-Object System.Drawing.Size(120, 30)
$btnLater.Add_Click({
   $global:choice = "Later"
   $timer.Stop()
   $form.Close()
})
$form.Controls.Add($btnLater)
# Timer fallback
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = $timeoutSeconds * 1000
$timer.Add_Tick({
   $timer.Stop()
   if (-not $global:choice) {
       $global:choice = $defaultAction
       $form.Close()
   }
})
$timer.Start()
# Show the form
$form.ShowDialog() | Out-Null
# Ensure fallback choice if still null (paranoia fallback)
if (-not $choice) {
   $choice = $defaultAction
}
# Decision
switch ($choice) {
   'Now' {
        Write-Output "Action: Reboot Now"
        Delete-Folder $folderPath1
        Delete-Folder $folderPath2
        New-RegistryKey $regPath $regName $regType $regValue
        New-RegistryKey $regPathMS $regNameMS $regTypeMS $regValueMS
        Prep-CleanupScript
        Build-SchedTask
        Restart-Computer -Force
        #Write-Output "Rebooted"
   }
   'Later' {
        Write-Output "Action: Wait 30 minutes, then reboot"
        Start-Sleep -Seconds 1800
        Delete-Folder $folderPath1
        Delete-Folder $folderPath2
        New-RegistryKey $regPath $regName $regType $regValue
        New-RegistryKey $regPathMS $regNameMS $regTypeMS $regValueMS
        Prep-CleanupScript
        Build-SchedTask
        Start-Job {
        Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.MessageBox]::Show("Rebooting in 60 seconds...", "Final Warning")
        } | Out-Null
        Start-Sleep -Seconds 60
        Restart-Computer -Force
        #Write-Output "rebooted"
   }
}