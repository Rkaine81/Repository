
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
    $MailSubject = 'Device Wipe Complete'

    ### if this log file doesn't exist, send regular e-mail
    If(!(Test-Path $attachment)) {Send-MailMessage -From $MailFrom -To $MailTo -Cc $MailCc -Subject $MailSubject -Body $emailBody -DeliveryNotificationOption $MailDelNotif -SMTPServer $MailServer}

    ### otherwise, send e-mail with log file as an attachment
    Else {Send-MailMessage -From $MailFrom -To $MailTo -Cc $MailCc -Subject $MailSubject -Body $emailBody -Attachments $attachment -DeliveryNotificationOption $MailDelNotif -SMTPServer $MailServer}
    # (Get-Content -Path $emailBody | Out-String)
    Start-Sleep -Seconds 5                                        # allow time to send e-mail
}

Send-choaEmail -emailBody "Testing for $EmailUser1." -attachment C:\CHOA\ComputerInfo.txt
