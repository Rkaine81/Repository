<#
Script Name: 
Script Version: 1.0
Author: Adam Eaddy
Date Created: 
Description: 
            Source script: https://smsagent.blog/2018/06/15/using-windows-10-toast-notifications-with-configmgr-application-deployments/
            URI example source: https://www.alexandrumarin.com/working-with-toast-notifications-and-using-powershell-scripts-as-button-actions/
Changes:    Added variables for $text1 and $text2 values.
            Added calculations for current uptime, deadline details, and individual time values. 
            Added detailed body message.
            Added $remoteMaxDays value.
            Added section to dynamically create choaRestart.cmd file.
            Create custom URI in windows registry


/#>

# Required parameters
$Title = "Reboot Notification" #This is currently hidden
$SubtitleText = "Your computer needs to be rebooted."
$HeaderFormat = "ImageOnly" # Choose from "TitleOnly", "ImageOnly" or "ImageAndTitle"
[INT]$rebootMaxDays = "20"
$text1 = "Reboot Notification"
$text2 = "CHOA IT"

#Nothing here needs to be modified, but it has to be defined prior to the text body.
#Calculate boot time and deadline times
$lastBootTime = Get-CimInstance -ClassName win32_operatingsystem | select -ExpandProperty lastbootuptime
$today = Get-Date
$diff = $today - $lastBootTime
$dayDiff = ($diff.Days)
$hourDiff = ($diff.Hours)
$minDiff = ($diff.Minutes)
$maxDeadline = $today.AddDays($rebootMaxDays)

#Text body content (This can be modified.  Do not change the variables.)
$BodyText = "It has been $dayDiff days, $hourDiff hours, and $minDiff minutes since your last reboot.  Please reboot your computer as soon as possible."

#Audio notification
$AudioSource = "ms-winsoundevent:Notification.Default"

# Base64 string for an image, see Images section below to create the string
$Base64Image = "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"

# Deployment deadline
#[datetime]$Deadline = $maxDeadline - $diff



###########################################################
#Do not Modify

## Images
# Convert an image file to base64 string
<#
$File = "C:\Users\<USERID>\Pictures\ICON_EV_LOGO_Resized.png"
$Image = [System.Drawing.Image]::FromFile($File)
$MemoryStream = New-Object System.IO.MemoryStream
$Image.Save($MemoryStream, $Image.RawFormat)
[System.Byte[]]$Bytes = $MemoryStream.ToArray()
$Base64 = [System.Convert]::ToBase64String($Bytes)
$Image.Dispose()
$MemoryStream.Dispose()
$Base64 | out-file "C:\Users\<USERID>\Pictures\ICON_EV_LOGO_Resized.txt" # Save to text file, copy and paste from there to the $Base64Image variable
/#>


#Creating Restart file
if (!(test-path C:\ProgramData\Toast)) { New-Item -ItemType Directory -Path C:\ProgramData -Name Toast}
if (!(test-path C:\ProgramData\Toast\choaRestart.cmd)) { 
    [System.IO.File]::WriteAllText("C:\ProgramData\Toast\choaRestart.cmd", "%windir%\System32\shutdown.exe /r /t 0 /f")
}

#Registering the ToastRestartProtocol custom URI in HKEY_CLASSES_ROOT
if (!(Test-Path "Registry::HKEY_CLASSES_ROOT\toastrestartprotocol\shell\open\command")) {
    New-Item -Path "Registry::HKEY_CLASSES_ROOT\toastrestartprotocol" -Force
    New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\toastrestartprotocol" -Name "(Default)" -PropertyType String -Value "URL:PowerShell Protocol" -Force
    New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\toastrestartprotocol" -Name "URL Protocol" -PropertyType String -Value "" -Force
    New-Item -Path "Registry::HKEY_CLASSES_ROOT\toastrestartprotocol\DefaultIcon" -Force
    New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\toastrestartprotocol\DefaultIcon" -Name "(Default)" -PropertyType String -Value "powershell.exe,1" -Force
    New-Item -Path "Registry::HKEY_CLASSES_ROOT\toastrestartprotocol\shell" -Force
    New-Item -Path "Registry::HKEY_CLASSES_ROOT\toastrestartprotocol\shell\open" -Force
    New-Item -Path "Registry::HKEY_CLASSES_ROOT\toastrestartprotocol\shell\open\command" -Force
    New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\toastrestartprotocol\shell\open\command" -Name "(Default)" -PropertyType String -Value "C:\ProgramData\Toast\choaRestart.cmd %1" -Force
}

# Calculated parameters
If ($Deadline)
{
    $TimeSpan = $Deadline - [datetime]::Now
}

# Create an image file from base64 string and save to user temp location
If ($Base64Image)
{
    $ImageFile = "$env:TEMP\ToastLogo.png"
    [byte[]]$Bytes = [convert]::FromBase64String($Base64Image)
    [System.IO.File]::WriteAllBytes($ImageFile,$Bytes)
}
 
# Load some required namespaces
$null = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
$null = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]

# Register the AppID in the registry for use with the Action Center, if required
$app =  '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
$AppID = "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\\WindowsPowerShell\\v1.0\\powershell.exe"
$RegPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings'

if (!(Test-Path -Path "$RegPath\$AppId")) {
    $null = New-Item -Path "$RegPath\$AppId" -Force
    $null = New-ItemProperty -Path "$RegPath\$AppId" -Name 'ShowInActionCenter' -Value 1 -PropertyType 'DWORD'
}

# Define the toast notification in XML format
[xml]$ToastTemplate = @"
<toast scenario="reminder">
    <visual>
    <binding template="ToastGeneric">
        <text>$text1</text>
        <text>$text2</text>        
        <group>
            <subgroup>
                <text hint-style="title" hint-wrap="true" >$Title</text>
            </subgroup>
        </group>
        <group>          
            <subgroup>     
                <text hint-style="subtitle" hint-wrap="true" >$SubtitleText</text>
            </subgroup>
        </group>
        <group>
            <subgroup>     
                <text hint-style="body" hint-wrap="true" >$BodyText</text>
            </subgroup>
        </group>
    </binding>
    </visual>
    <actions>
      <action content="Reboot Now" activationType="protocol" arguments="toastrestartprotocol://restart" />
      <action content="Another time..." arguments="" />
    </actions>
    <audio src="$AudioSource"/>
</toast>
"@

# Change up the headers as required
If ($HeaderFormat -eq "TitleOnly")
{
    $ToastTemplate.toast.visual.binding.group[0].subgroup.InnerXml = "<text hint-style=""title"" hint-wrap=""true"" >$Title</text>"
}
If ($HeaderFormat -eq "ImageOnly")
{
    $ToastTemplate.toast.visual.binding.group[0].subgroup.InnerXml = "<image src=""$ImageFile""/>"
}
If ($HeaderFormat -eq "ImageAndTitle")
{
    $ToastTemplate.toast.visual.binding.group[0].subgroup.InnerXml = "<text hint-style=""title"" hint-wrap=""true"" >$Title</text><image src=""$ImageFile""/>"
}

# Add a deadline if required
If ($Deadline)
{
$DeadlineGroups = @"
        <group>
            <subgroup>
                <text hint-style="base" hint-align="left">Deadline</text>
                 <text hint-style="caption" hint-align="left">$(Get-Date -Date $Deadline -Format "dd MMMM yyy HH:mm")</text>
            </subgroup>
            <subgroup>
                <text hint-style="base" hint-align="right">Time Remaining  .</text>
                <text hint-style="caption" hint-align="right">$($TimeSpan.Days) days $($TimeSpan.Hours) hours $($TimeSpan.Minutes) minutes  .</text>
            </subgroup>
        </group>
"@
    $ToastTemplate.toast.visual.binding.InnerXml = $ToastTemplate.toast.visual.binding.InnerXml + $DeadlineGroups

}

# Load the notification into the required format
$ToastXml = New-Object -TypeName Windows.Data.Xml.Dom.XmlDocument
$ToastXml.LoadXml($ToastTemplate.OuterXml)

# Display
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($app).Show($ToastXml)