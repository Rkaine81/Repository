<#
Script Name: SCCMClientRefresh.ps1
Script Version: 1.0
Author: Adam Eaddy
Date Created: 03/24/2021
Description: This script will:
1. Stop the SMS Agent Host Service
2. Delete 2 SMS computer certificates
3. Delte the SMSCfg.ini file
4. Start the SMS Agent Host Service
5. Run the SCCM client retrieval policy
6. Run full HW inventory
Changes: 
/#>

#Target Machines:
$Computers= "localhost"

#Stopping SMS service
write-output "Stopping SMS Service"
$SMSSERVICE = Get-Service -Name CcmExec
Stop-Service -InputObject $SMSSERVICE

#Delte SMS Certificates
write-output "Deleting Certificates"
Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\SystemCertificates\SMS\Certificates\*' -force

#Pause 20 seconds 
write-output "Waiting"
Start-Sleep -Seconds 20

#Delete SMSCFG.ini file
write-output "Deleting Cfg file"
$CMCFGFILE = "C:\Windows\smscfg.ini"
$OLDCFG = Get-Item -Path $CMCFGFILE
$DEST = $OLDCFG.DirectoryName
$BKUP = $OLDCFG.Name+".old"
$BKUPFILE = "$DEST\$BKUP"

$CFGFILETEST = test-path -Path $CMCFGFILE
$BKUPFILETEST = test-path -Path $BKUPFILE

if ($BKUPFILETEST -eq $true) {

    Remove-Item -Path $BKUPFILE -Force
}
if ($CFGFILETEST -eq $true) {

    Copy-Item -Path $CMCFGFILE -Destination $BKUPFILE -Force
    Remove-Item -Path $CMCFGFILE -Force
}

#Starting SMS service
write-output "Starting SMS Service"
Start-Service -InputObject $SMSSERVICE

#Pause 30 seconds 
write-output "Waiting"
Start-Sleep -Seconds 30

#Running Policies
#Machine Policy Retrieval Cycle
Write-Host "==== Machine Policy Retrieval Cycle ====" -ForegroundColor Red -BackgroundColor White
Invoke-WMIMethod -ComputerName $Computers -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000021}"

#Machine Policy Evaluation Cycle
Write-Host "==== Machine Policy Evaluation Cycle ====" -ForegroundColor Red -BackgroundColor White
Invoke-WMIMethod -ComputerName $Computers -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000022}"

#Remove HWInv WMI Object to trigger full HW Inventory
Get-WmiObject -ComputerName $Computers -Namespace root\ccm\invagt -Class inventoryactionstatus | Where-Object {$_.inventoryactionid -eq "{00000000-0000-0000-0000-000000000001}"} | Remove-WmiObject

#Hardware Inventory Cycle
Write-Host "==== Hardware Inventory Cycle ====" -ForegroundColor Red -BackgroundColor White
Invoke-WMIMethod -ComputerName $Computers -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000001}"

#Machine Policy Retrieval Cycle
Write-Host "==== Machine Policy Retrieval Cycle ====" -ForegroundColor Red -BackgroundColor White
Invoke-WMIMethod -ComputerName $Computers -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000021}"

#Machine Policy Evaluation Cycle
Write-Host "==== Machine Policy Evaluation Cycle ====" -ForegroundColor Red -BackgroundColor White
Invoke-WMIMethod -ComputerName $Computers -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000022}"
