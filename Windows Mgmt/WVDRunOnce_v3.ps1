<#
Script Name: WVDRunOnce_v2.ps1
Script Version: 3.0
Author: Adam Eaddy
Date Created: 08/04/2021
Date Updated: 08/16/2021
Description: The purpose of this script is to Run once on each WVD host to install Qualys on host 0001 and run Remediant registration on every host.
Create and run cleanup script to delete script and delete qualys dir and WVDConfig.inf.
Changes:
v1.2 - Added directory cleanup.  Hide Runonce directory. Delete scheduled task.
v2.0 - Updated credemtial process.
v3.0 - Added logging and software install function
v3.0 - added SCCM login
/#>


#Set Variables



$infVal0 = "tfayd\svc206460448"
$infVal1 = [string][char[]][int[]]("115.99.99.109.50.48.49.53.87.84.69".Split(".")) -replace " "
$infVal2 = ConvertTo-SecureString $infVal1 -AsPlainText -Force
$infVal3 = New-Object System.Management.Automation.PSCredential ($infVal0, $infVal2)



$HOSTNAME = $env:COMPUTERNAME



### Declare Functions ###

#Logging Function
#Example: Write-Log "This is a log entry."
Function Write-Log {

    param(
        [Parameter(Mandatory=$true)]
        [string]$VALUE
    )

    $SDATE = get-date -Format MMddyyyy
    $LOGPATH = "C:\USGDAT"
    #Set Log name
    $LOGFILE = "firstRun.log"
    $FULLLOGPATH = "$LOGPATH\$LOGFILE"

    write-output "$(get-date): $VALUE" | out-file $FULLLOGPATH -Append -Force -NoClobber

}

Function Install-CoreApps {

    param(
        [Parameter(Mandatory=$true)]
        [string]$APPINSTALLPATH,
        [Parameter(Mandatory=$true)]
        [string]$APPPARAM
    
    )

    

    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Beginning the installation of the Application(s)."



        $APP = Get-ChildItem -Path $APPINSTALLPATH | where {$_ -like "*.EXE" -or $_ -like "*.msi"}


            Write-Log "Installing $($APP.Name)."
                
            if ($APP.Name -like "*.msi") {

                WRITE-OUTPUT "MSI: $($APP.Name)"
                Write-Output "$(get-date)"
                start-process msiexec.exe -ArgumentList "/i $(($APP).Fullname) $($APPPARAM)"

                }elseif ($APP.Name -like "*.EXE"){

                #Start-Process $APP.FullName -argumentlist "/D:C" -wait
                WRITE-OUTPUT "EXE: $($APP.Name)"
                Write-Output "$(get-date)"
                Start-Process $APP.FullName -argumentlist $APPPARAM
              
                }                           

                Write-Log "Please check C:\USGDAT for application install logs."  

}


#Example: Install-Apps -APPINSTALLPATH "C:\Install" -APPPARAM "/D:C"



#Run Qualys installer on Host 0000
if ($HOSTNAME -like "*0000") {
    #Start-Process "C:\qualys\QualysCloudAgent.exe" -argumentlist "CustomerId={471d68df-e6a8-4ead-829a-1d6c96f0441a} ActivationId={4602893e-49e8-411f-889a-babcdcb769dc} WebServiceUri=https://qagpublic.qg3.apps.qualys.com/CloudAgent/"
    
        Try {

            Install-CoreApps -APPINSTALLPATH "C:\qualys\QualysCloudAgent.exe" -APPPARAM "CustomerId={471d68df-e6a8-4ead-829a-1d6c96f0441a} ActivationId={4602893e-49e8-411f-889a-babcdcb769dc} WebServiceUri=https://qagpublic.qg3.apps.qualys.com/CloudAgent/"
            start-sleep -Seconds 10

        }Catch{
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Error: Could not install the applications. Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        }

}





#Register host in Remediant
Invoke-Command -ComputerName eclapwp00556.tfayd.com -ScriptBlock { powershell.exe -file D:\Remediant\RemoteEnrollWLogOAM2.ps1 -host_name $USING:HOSTNAME } -Credential $infVal3

#Remove-Item -Path C:\temp -Recurse -Force
#Remove-Item -Path C:\Qualys -Recurse -Force
$f=get-item C:\runonce -Force
$f.attributes="Hidden"
$g=get-item C:\temp -Force
$g.attributes="Hidden"
$h=get-item C:\Qualys -Force
$h.attributes="Hidden"

$TASK = Get-Scheduledtask -TaskName WVDSetup
Unregister-ScheduledTask -InputObject $TASK -Confirm:$false