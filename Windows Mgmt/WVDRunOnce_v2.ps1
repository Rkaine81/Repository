<#
Script Name: WVDRunOnce_v2.ps1
Script Version: 2.0
Author: Adam Eaddy
Date Created: 08/04/2021
Date Updated: 08/16/2021
Description: The purpose of this script is to Run once on each WVD host to install Qualys on host 0001 and run Remediant registration on every host.
Create and run cleanup script to delete script and delete qualys dir and WVDConfig.inf.
Changes:
v1.2 - Added directory cleanup.  Hide Runonce directory. Delete scheduled task.
v2.0 - Updated credemtial process.
/#>



#Set Variables


$infVal3 = Import-Clixml -Path "C:\temp\WVDConfig.xml"

$HOSTNAME = $env:COMPUTERNAME


#Run Qualys installer on Host 0001
if ($HOSTNAME -like "*0001") {
    Start-Process "C:\qualys\QualysCloudAgent.exe" -argumentlist "CustomerId={471d68df-e6a8-4ead-829a-1d6c96f0441a} ActivationId={4602893e-49e8-411f-889a-babcdcb769dc} WebServiceUri=https://qagpublic.qg3.apps.qualys.com/CloudAgent/"
}

Start-Sleep 10

#Register host in Remediant
Invoke-Command -ComputerName eclapwp00556.tfayd.com -ScriptBlock { powershell.exe -file D:\Remediant\RemoteEnrollWLogOAM2.ps1 -host_name $USING:HOSTNAME } -Credential $infVal3

Remove-Item -Path C:\temp -Recurse -Force
Remove-Item -Path C:\Qualys -Recurse -Force
$f=get-item C:\runonce -Force
$f.attributes="Hidden"

$TASK = Get-Scheduledtask -TaskName WVDSetup
Unregister-ScheduledTask -InputObject $TASK -Confirm:$false