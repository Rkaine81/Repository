#Script Name: RunSCCMClientActions.ps1
#Script Version: 1.1
#Author: Adam Eaddy
#Date Created: 03/11/2021
#Description: This script will invoke Software Center Client Actions.
#Changes: 1.1 - Added step to remove SCCM HW Inv WMI Object to trigger full HW Inventory.


#Target Machines:
$Computers= "localhost"

#START
Write-Host ==== Start Cycles ==== -ForegroundColor Red -BackgroundColor White `n

#Remove HWInv WMI Object to trigger full HW Inventory
Get-WmiObject -Namespace root\ccm\invagt -Class inventoryactionstatus | Where-Object {$_.inventoryactionid -eq "{00000000-0000-0000-0000-000000000001}"} | Remove-WmiObject

#Application Deployment Evaluation Cycle
Write-Host "==== Application Deployment Evaluation Cycle ====" -ForegroundColor Red -BackgroundColor White
#Invoke-WMIMethod -ComputerName $Computers -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000121}"

#Discovery Data Collection Cycle
Write-Host "==== Discovery Data Collection Cycle ====" -ForegroundColor Red -BackgroundColor White
#Invoke-WMIMethod -ComputerName $Computers -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000003}"

#File Collection Cycle
Write-Host "==== File Collection Cycle ====" -ForegroundColor Red -BackgroundColor White
#Invoke-WMIMethod -ComputerName $Computers -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000010}"

#Hardware Inventory Cycle
Write-Host "==== Hardware Inventory Cycle ====" -ForegroundColor Red -BackgroundColor White
Invoke-WMIMethod -ComputerName $Computers -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000001}"

#Machine Policy Retrieval Cycle
Write-Host "==== Machine Policy Retrieval Cycle ====" -ForegroundColor Red -BackgroundColor White
Invoke-WMIMethod -ComputerName $Computers -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000021}"

#Machine Policy Evaluation Cycle
Write-Host "==== Machine Policy Evaluation Cycle ====" -ForegroundColor Red -BackgroundColor White
Invoke-WMIMethod -ComputerName $Computers -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000022}"

#Software Inventory Cycle
Write-Host "==== Software Inventory Cycle ====" -ForegroundColor Red -BackgroundColor White
#Invoke-WMIMethod -ComputerName $Computers -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000002}"

#Software Metering Usage Report Cycle
Write-Host "==== Software Metering Usage Report Cycle ====" -ForegroundColor Red -BackgroundColor White
#Invoke-WMIMethod -ComputerName $Computers -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000031}"

#Software Updates Assignments Evaluation Cycle
Write-Host "==== Software Updates Assignments Evaluation Cycle ====" -ForegroundColor Red -BackgroundColor White
#Invoke-WMIMethod -ComputerName $Computers -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000114}"

#Software Update Scan Cycle
Write-Host "==== Software Update Scan Cycle ====" -ForegroundColor Red -BackgroundColor White
#Invoke-WMIMethod -ComputerName $Computers -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000113}"

#State Message Refresh
Write-Host "==== State Message Refresh ====" -ForegroundColor Red -BackgroundColor White
#Invoke-WMIMethod -ComputerName $Computers -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000111}"

#Windows Installers Source List Update Cycle
Write-Host "==== Windows Installers Source List Update Cycle ====" -ForegroundColor Red -BackgroundColor White
#Invoke-WMIMethod -ComputerName $Computers -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000032}"

#FINISH
Write-Host ==== Finished cycles ==== -ForegroundColor Red -BackgroundColor White