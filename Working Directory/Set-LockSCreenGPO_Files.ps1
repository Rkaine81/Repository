<#
Script Name: Set-LockScreenGPO_Files.ps1
Script Version: 1.0
Author: Adam Eaddy
Edited by: 
Date Created: 04/09/2025
Date Updated: 
Description: The purpose of this script is to automatically update the Group Policy that will set the Windows client lockscreen.  This script will check
             for the presence of new lock screen image files that match the current day.  If the files are found, they will be copied into the proper share,
             and the GPO settings will be updated accordingly.
Changes:

/#>


# Variables

$uploadPath = "\\choa-cifs\install\CM_P01\00_ToolsTestTemplates\AE\Lockscreens"
$gpoFilePath = "\\choa-cifs\install\CM_P01\00_ToolsTestTemplates\AE\Lockscreens2"
$year = (get-date).Year
$actualDate = get-date -Format yyyy-M-d
$gpoName = "WS_Visual_Messaging_Automation_Test"
$xmlFile = "\\choa-cifs\install\CM_P01\00_ToolsTestTemplates\AE\LockscreenFiles\Files.xml"
$log = @()

# /Variables


# Functions

Function Get-OldFile ($inFromPaths) {
    $diffs = @()
    # Loop through each path and extract the date portion
    foreach ($fpath in $inFromPaths) {
        If ($null -ne $fpath) {
           # Split the path and get the relevant part for the date
           $splitPath = $fpath.Split("\")[-1]
           $fileDateString = $splitPath.Split(" ")[0]
           # Parse the file date
           $fileDate = [DateTime]$fileDateString
           # Calculate the difference in days
           $dayDifference = (Get-Date) - $fileDate
           $psObj = [PSCustomObject]@{
                Path = $fpath
                DateDiff = $dayDifference.Days
            }
           $diffs += $psObj
        }
    }

    $diffs
}

Function Send-choaEmail {
Param (
    $emailBody,
    $attachment
)
    ### e-mail recipient list
    $EmailUser1 = 'Adam Eaddy <adam.eaddy@choa.org>'
    $EmailUser2 = 'Null User <null.user@choa.org>'

    ### To, Cc and Bcc fields of e-mail
    # $MailTo = $EmailUser1
    $MailTo = $EmailUser1
    # $MailTo = $EmailUser5
    $MailCc = $EmailUser2
    # $MailBcc = $EmailUser1                                # add "-Bcc $MailBcc" after "-Cc $MailCc" to Send-MailMessage command

    ### e-mail attachments
    # $File1Attachment = "E:\Folder\report1.txt"
    # $File2Attachment = "E:\Folder\report2.txt"
    # $MailAttachments = @($File1Attachment,$File2Attachment)     # correct way to send multiple attachments

    ### e-mail general settings
    $MailFrom = $EmailUser1
    $MailDelNotif = 'OnFailure'                                # or 'OnSuccess, OnFailure'
    $MailServer = 'mail.choa.org'
    $MailSubject = "Lockscreen Update Report - $(get-date)"

    ### if this log file doesn't exist, send regular e-mail
    If(!(Test-Path $attachment)) {Send-MailMessage -From $MailFrom -To $MailTo -Cc $MailCc -Subject $MailSubject -Body $emailBody -DeliveryNotificationOption $MailDelNotif -SMTPServer $MailServer}

    ### otherwise, send e-mail with log file as an attachment
    Else {Send-MailMessage -From $MailFrom -To $MailTo -Cc $MailCc -Subject $MailSubject -Body $emailBody -Attachments $attachment -DeliveryNotificationOption $MailDelNotif -SMTPServer $MailServer}
    # (Get-Content -Path $emailBody | Out-String)
    Start-Sleep -Seconds 5                                        # allow time to send e-mail
}

Function Write-Log {

    param(
        [Parameter(Mandatory=$true)]
        [string]$VALUE
    )

    $SDATE = get-date -Format MMddyyyy
    $LOGPATH = "C:\CHOA"
    #Set Log name
    $LOGFILE = "SetLockscreen_$SDATE.log"
    $FULLLOGPATH = "$LOGPATH\$LOGFILE"

    write-output "$(get-date): $VALUE" | out-file $FULLLOGPATH -Append -Force -NoClobber

}

# /Functions



#Check for new files in Upload Share
If (Test-path "$uploadPath\$year\$actualDate*") {
    write-Log "New lockscreen files found in $uploadPath\$year."
    $log += "New lockscreen files found in $uploadPath\$year."
}else{
    Break
    #Exit 1
}

#Copy new files to GPO Share
$uploadFiles = get-childitem "$uploadPath\$year\$actualDate*"
If ($null -ne $uploadFiles) {
    try {
        Write-Log "The new files found are:"
        Write-Log $uploadFiles.Name
        Write-Log "Beginning file copy to $gpoFilePath." 
        Copy-Item $uploadFiles $gpoFIlePath -Force
    }
    Catch {
        Write-Log "Error. Failed to copy files. Exiting script." 
        Break 
        #Exit 1 
    }
}

If (Test-path $xmlFile) {
    Write-Log "Beginning modification of $xmlFile."
}else{
    Write-Log "Could not get content of $xmlFile."
    Break
    #Exit 1
}
 
#Get XML Document to update File list
$XMLDocument = [XML](Get-Content $xmlFile) 
$XMLDocFiles = $XMLDocument.Files.File
$XMLDocProperties = $XMLDocument.Files.File.Properties

#Determine Next Lockscreen number (1-4)
$nums = @()
$expected = 1..4
$targetPaths = $XMLDocument.Files.File.Properties.targetPath
foreach ($path in $targetPaths) {
    $a = ($path.Substring($path.Length - 5, 5)).trimend(".jpg")
    $nums += $a 
}
$missing = $expected | Where-Object { $_ -notin $nums }
$newFileName = "C:\Windows\Web\Wallpaper\CHOA\CHOA_Lockscreen$missing.jpg"
Write-Log "The new lock screen file name will be:"
write-log $newFileName

#Get oldest file entry
$fromPaths = $XMLDocument.Files.File.Properties.FromPath
$diffs = Get-OldFile $fromPaths
$maxValue = ($diffs.DateDiff | Measure-Object -Maximum).Maximum
$removalObjs = @()
Foreach ($diff in $diffs) {
    If ($diff.DateDiff -eq $maxValue) {
        $psObj1 = [PSCustomObject]@{
            Path = $diff.Path
            DateDiff = $diff.DateDiff
        }
        $removalObjs += $psObj1
    }
}
Write-Log "The files that are being replaced are:"
write-log $removalObjs.Path[0]
write-log $removalObjs.Path[1]
#Find Number to replace in Delete entry
$removalObjs2 = @()
Foreach ($removalObj in $removalObjs) {
    Foreach ($XMLDocProp in $XMLDocProperties) {
        If (($removalObj.Path) -eq ($XMLDocProp.fromPath)) {
            $psObj2 = [PSCustomObject]@{
                Path = $XMLDocProp.targetPath
            }
            $removalObjs2 += $psObj2
        }
    }
}
If ($removalObjs2.Path[0] -eq $removalObjs2.Path[1]) { 
    $removalFile = $removalObjs2.Path[0]
    Write-Log "The file name that will be removed is $removalFile."
}else{
    Write-Log "Could not determine the proper file to remove."
    Break
    #Exit 1
}


#Modify Delete Entry & Filter
$node = $XMLDocument.Files.File.Properties | 
where {$_.Action -eq 'D'}
$nodeF = $XMLDocument.Files.File | 
where {$_.Name -eq ($node.targetPath).split("\")[-1]}
$nodeG = $nodeF.Filters.FilterFile
Write-Log "Modifying the Delete Object."
# Set the new values
Write-Log "Changing value for Delete Object from {$($node.targetPath)} to {$removalFile}."
$node.targetPath = $removalFile
Write-Log "Changing value for Delete Object from {$($nodGe.path)} to {$removalFile}."
$nodeG.path  = $removalFile
Write-Log "Changing value for Delete Object from {$($nodeF.name)} to {$($removalFile.split("\")[-1])}."
$nodeF.name = $removalFile.split("\")[-1]
Write-Log "Changing value for Delete Object from {$($node.targetPath)} to {$($removalFile.split("\")[-1])}."
$nodeF.status = $removalFile.split("\")[-1]
Write-Log "Changing value for Delete Object from {$($node.targetPath)} to {$removalFile}."
$nodeF.changed = (Get-Date -Format "yyyy-MM-dd HH:mm:ss").ToString()


#Modify 2 Copy Entries
#Modify the one that matches $removalFile and update to missing file, and set the apprpriate JPEG file.
$gpoFiles = Get-ChildItem $gpoFilePath | where {$_.Mode -eq "-a----"}
$gDiffs = Get-OldFile ($gpoFiles.FullName)
#Determine older file
$gMaxValue = ($gDiffs.DateDiff | Measure-Object -Minimum).Minimum
$gfilesToMove = @()
Foreach ($gDiff in $gDiffs) {
    If ($gDiff.DateDiff -eq $gMaxValue) {
        $psObj4 = [PSCustomObject]@{
            Path = $gdiff.Path
            DateDiff = $gdiff.DateDiff
        }
        $gfilesToMove += $psObj4
    }
}

$x=0
$zNodes = $XMLDocument.Files.File | 
where {$_.name -eq ($removalFile).split("\")[-1] -and $_.image -ne "3"}
Foreach ($zNode in $zNodes) {
    $zNode.name = $newFileName.split("\")[-1]
    $zNode.status = $newFileName.split("\")[-1]
    $zNode.changed = (Get-Date -Format "yyyy-MM-dd HH:mm:ss").ToString()
    $zNode.Filters.FilterCollection.FilterFile.path = $newFileName
    $zNode.Properties.fromPath = ($gfilesToMove)[$x].Path
    $zNode.Properties.targetPath = $newFileName
    $x += 1
}
#Save XML doc
$XMLDocument.Save($xmlFile)


# Archive old wallpaper files
# Create folder for YEAR if not exist
If (!(Test-Path "$gpoFilePath\old\$year")) {
    New-Item -ItemType Directory -Path "$gpoFilePath\old" -Name $year 
}
$oldFiles = Get-ChildItem $gpoFilePath | where {$_.Mode -eq "-a----"}
$fDiffs = Get-OldFile ($oldFiles.FullName)
#Determine older file
$fMaxValue = ($fDiffs.DateDiff | Measure-Object -Maximum).Maximum
$filesToMove = @()
Foreach ($fDiff in $fDiffs) {
    If ($fDiff.DateDiff -eq $fMaxValue) {
        $psObj3 = [PSCustomObject]@{
            Path = $fdiff.Path
            DateDiff = $fdiff.DateDiff
        }
        $filesToMove += $psObj3
    }
}
Foreach ($fileToMove in $filesToMove) {
    Try {
        Move-Item $fileToMove.path "$gpoFilePath\old\$year" -Force -ErrorAction Stop
    }
    Catch {
        Write-Output "Failed to move files."
    }
}

Start-Sleep -Seconds 3600

<#

# Check if GPO exists
$gpo = Get-GPO -Name $gpoName -ErrorAction Stop
# Set new Lock Screen image
Set-GPRegistryValue -Name $gpoName `
   -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" `
   -ValueName "LockScreenImage" `
   -Type String `
   -Value $newFileName
Write-Output "GPO has been updated with new Lock Screen and Logon image settings."

#>


Send-choaEmail -emailBody "Testing for $EmailUser1." -attachment C:\CHOA\ComputerInfo.txt