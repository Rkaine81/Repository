<#
Script Version: 1.0
Author: Adam Eaddy
Edited by: 
Date Created: 16/04/2024
Date Updated: 
Description: The purpose of this script is to gather log files for troubleshooting device issues.
Changes:

/#>


$ErrorActionPreference     = "SilentlyContinue"
$Timestamp2                = Get-Date -format "MMddyyy HHmmss"
$SDATE                     = Get-Date -Format MM-dd-yyyy
$ComputerName              = $env:computername
$OsDrive                   = Get-Volume -FileSystemLabel "Windows"
$OsDriveLetter1            = $OsDrive.DriveLetter
If ($OsDriveLetter1 -ne $NULL)    { $OsDriveLetter = $OsDriveLetter1 + ':' }
Else {$WMILD  = gwmi win32_logicaldisk -Filter "DriveType = '3'"
ForEach ($LD in $WMILD) {$LDName   = $LD.VolumeName
If ($LDName -eq "Windows") {$OsDriveLetter = $LD.DeviceID}}}
$LOGPATH                   = "$OsDriveLetter\CHOA"
$LOGFILE                   = "LogGather" + "-" + "$ComputerName" + "-" + "$SDATE.log"
$ZIPFILE                   = "Logs" + "-" + "$ComputerName" + "-" + "$SDATE.zip"
$FULLLOGPATH               = "$LOGPATH\$LOGFILE"
$LocalLogPath              = "$OsDriveLetter\CHOA\WindowsLogs\$Timestamp2"
$BasePath                  = "\\choa-cifs\install\WindowsLogs"
$WinLogPath                = "\\choa-cifs\install\WindowsLogs\$ComputerName\$Timestamp2"
$network                   = "true"

Set-Variable -Name EventAgeDays -Value 7     #we will take events for the latest 7 days
Set-Variable -Name LogNames -Value @("Application", "System", "Setup")  # Checking app and system logs
Set-Variable -Name EventTypes -Value @("Error", "Warning")  # Loading only Errors and Warnings
Set-Variable -Name ExportFolder -Value "$OsDriveLetter\CHOA\"


#region Functions

#Logging Function
Function Write-Log {

    param(
        [Parameter(Mandatory=$true)]
        [string]$VALUE
    )

    $ComputerName = $env:computername
    $SDATE = get-date -Format MM-dd-yyyy
    $LOGPATH = "$OsDriveLetter\CHOA"
    #Set Log name
    $LOGFILE = "LogGather" + "-" + "$ComputerName" + "-" + "$SDATE.log"
    $FULLLOGPATH = "$LOGPATH\$LOGFILE"

    write-output "$(get-date): $VALUE" | out-file $FULLLOGPATH -Append -Force -NoClobber

}

# File Copy Function 
function Copy-File {
<#
Copy-File -Source <source> -destination <dest>
Exit Codes:
0 = file copy successful
1 = file copy failed
2 = Source path not found
#>
param( [string]$Source, [string]$Destination )

    If (Test-Path $Source) {
        Copy-Item -Path $Source -Destination $Destination  -PassThru -Force                                                                    
        If (!(Test-Path $Destination)) { 
            return 1  
        }Else{ 
            return 0
        }                                                                                                                        
    }Else{                                                                    
        return 2                                                                                                                    
    }
}

#Create registry path if it doesn't exist. Modify entry value. 
#Example: Write-RegKey "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" "DWord" "1"
 Function Write-RegKey{
 
    Param(
        [Parameter(Mandatory=$true)]
        [string]$registryPath,
        [Parameter(Mandatory=$true)]
        [string]$regName,
        [Parameter(Mandatory=$true)]
        [string]$regType,
        [Parameter(Mandatory=$true)]
        [string]$regValue
    )
    

        
    Write-output "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-output "Checking for the Registry key: $registryPath\$regName."
    If(!(Test-RegistryValue $registryPath $regName)){Write-output "Attempting to write RegKey: $registryPath\$regName"}

    If(!(Test-Path $registryPath)){
        Write-output "Attempting to write RegKey: $registryPath."
        New-Item -Path $registryPath -Force
            If(Test-Path $registryPath){Write-output "RegKey: $registryPath exists."}else{Write-Log "Error: The reg key $registryPath could not be created."}
    }

    $WRCHECK = $null
    if (((Get-ItemProperty -Path $registryPath -Name $regName).$regname) -ne $regValue) {
        Write-Output "The Registry Value data does not match the required data value.  Settings the data value to: $regValue"
        New-ItemProperty -Path $registryPath -Name $regName -PropertyType $regType -Value $regValue -Force | Write-Output
        $WRCHECK = "1"
    }else{
        Write-output "The registry value is already set to $regValue."
    }


    if ($WRCHECK = "1"){
        if (((Get-ItemProperty -Path $registryPath -Name $regName).$regname) -eq $regValue) {
            Write-output "The Registry Value data is set to: $regValue"
        }else{
            Write-Log "Error: The registry value data could not be set for $regName."
        }
    }
    
}

#endregion


Write-Log "--- Beginning the log gather process. ---"


#Creating network folder for user and date
Write-Log "--- Creating local log directory ---"
if (!(test-path $LocalLogPath)) {New-Item -ItemType Directory -Path $LocalLogPath}
if (test-path $LocalLogPath) {
    write-log "Successfully created $LocalLogPath."
}else{
    write-log "Failed to create $LocalLogPath."
    exit 1
}


#Gather Event logs
Write-Log "--- Exporting and Gathering Event Logs ---"
$el_c = @()   #consolidated error log
$now=get-date
$startdate=$now.adddays(-$EventAgeDays)
$ExportFile=$LocalLogPath + "\eventLog" + "-" + $now.ToString("yyyy-MM-dd") + ".csv"  # we cannot use standard delimiteds like ":"
Write-Log "Event Log file: $ExportFile."
if (test-path $ExportFile) {Remove-Item $ExportFile -Force}
foreach($log in $LogNames)
{
    Write-Host Processing $comp\$log
    $el = get-eventlog -log $log -After $startdate -EntryType $EventTypes
    $el_c += $el  #consolidating

}
$el_sorted = $el_c | Sort-Object TimeGenerated    #sort by time
Write-Host Exporting to $ExportFile
$FormatEnumerationLimit=-1
$el_sorted|Select EntryType, TimeGenerated, Source, EventID, Message| Export-CSV $ExportFile -NoTypeInfo  #EXPORT
if (test-path $ExportFile) {write-log "Successfully exported Event Log via PowerShell to $ExportFile."}else{write-log "Failed to export Event Log via PowerShell to $ExportFile."}

ForEach ($log in $LogNames) {
    (Get-WmiObject -Class Win32_NTEventlogFile | Where-Object LogfileName -EQ "$log").BackupEventlog("$LocalLogPath\$log.evtx")
    if (test-path "$LocalLogPath\$log.evtx") {write-log "Successfully exported Event Log: $LocalLogPath\$log.evtx."}else{write-log "Failed to export Event Log: $LocalLogPath\$log.evtx."}
}

#Gather Windows Update Log
Write-Log "--- Exporting and Gathering Windows Update Logs ---"
Try {
    if (test-path "$LocalLogPath\WindowsUpdate.log") {Remove-Item "$LocalLogPath\WindowsUpdate.log" -Force}
    if (!(test-path "$LocalLogPath\WindowsUpdate.log")) {Get-WindowsUpdateLog -logpath "$LocalLogPath\WindowsUpdate.log"}
}
Catch{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    $FullMessage = $Error[0].Exception.GetType().FullName
        Write-Log "Error: Failed to run Get-WindowsUpdateLog successfully : Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
}
if (test-path "$LocalLogPath\WindowsUpdate.log") {write-log "Successfully exported Windows Update Log to $LocalLogPath\WindowsUpdate.log."}else{write-log "Failed to export Windows Update Log."}


#Copying Log Files to local directory to centralize content
Write-Log "--- Beginning the local file copy process. ---"
 #Source   Destination
$FilePaths=@(
@("$OsDriveLetter\Windows\Panther\Setupact.log", $LocalLogPath),                                     # Upgrade Success/fails during installation after the computer restarts for the second time - Setupact.log
@("$OsDriveLetter\Windows\Panther\setuperr.log", $LocalLogPath),                                     # Upgrade Success/fails during installation after the computer restarts for the second time - Setuperr.log
@("$OsDriveLetter\Windows\inf\setupapi.app.log", $LocalLogPath),                                     # Upgrade Success/fails during installation after the computer restarts for the second time - setupapi.app.log
@("$OsDriveLetter\Windows\inf\setupapi.dev.log", $LocalLogPath),                                     # Upgrade Success/fails during installation after the computer restarts for the second time - setupapi.dev.log
@("$OsDriveLetter\Windows\panther\PreGatherPnPList.log", $LocalLogPath),                             # Upgrade Success/fails during installation after the computer restarts for the second time - PreGatherPnPList.log
@("$OsDriveLetter\Windows\panther\PostApplyPnPList.log", $LocalLogPath),                             # Upgrade Success/fails during installation after the computer restarts for the second time - PostApplyPnPList.log
@("$OsDriveLetter\Windows\panther\miglog.xml", $LocalLogPath),                                       # Upgrade Success/fails during installation after the computer restarts for the second time - miglog.xml
@("$OsDriveLetter\Windows\memory.dmp", $LocalLogPath),                                               # Upgrade fails during installation after the computer restarts for the second time - memory.dmp
@("$OsDriveLetter\$Windows.~BT\Sources\panther\setupact.log", $LocalLogPath),                        # Upgrade fails during installation before the computer restarts for the second time - Setupact.log
@("$OsDriveLetter\$Windows.~BT\Sources\panther\miglog.xml", $LocalLogPath),                          # Upgrade fails during installation before the computer restarts for the second time - miglog.xml
@("$OsDriveLetter\Windows\setupapi.log", $LocalLogPath),                                             # Upgrade fails during installation before the computer restarts for the second time - setupapi.log
@("$OsDriveLetter\Windows\Logs\MoSetup\BlueBox.log", $LocalLogPath),                                 # Upgrade fails during installation before the computer restarts for the second time - BlueBox.log
@("$OsDriveLetter\$Windows.~BT\sources\panther\setupapi\setupapi.dev.log", $LocalLogPath),           # Log files created when an upgrade fails, and then you restore the desktop - setupapi.dev.log
@("$OsDriveLetter\$Windows.~BT\sources\panther\setupapi\setupapi.app.log", $LocalLogPath),           # Log files created when an upgrade fails, and then you restore the desktop - setupapi.app.log
@("$OsDriveLetter\$Windows.~BT\Sources\Rollback\setupact.log", $LocalLogPath),                       # Log files are created when an upgrade fails, and the installation rollback is initiated - setupact.log
@("$OsDriveLetter\$Windows.~BT\Sources\Rollback\setupact.err", $LocalLogPath),                       # Log files are created when an upgrade fails, and the installation rollback is initiated - setuperr.log
@("$OsDriveLetter\Windows\Logs\MoSetup\UpdateAgent.log", $LocalLogPath),                             # UpdateAgent.log
@("$OsDriveLetter\Windows\Logs\DISM\dism.log", $LocalLogPath),                                       # dism.log
@("$OsDriveLetter\Windows\CCM\Logs\smsts.log", $LocalLogPath))                                       # Config Mgr. task sequence log - SMSTS.log
    Try {
        foreach ($FilePath in $FilePaths) {
        
            $FILEP00 = $FilePath[0]
            $FILEP01 = $FilePath[1]

            #Write-Log "Copying $FILEP00 to $FILEP01"
            Write-Host "Checking for file: $FILEP00."
            Write-Log "Checking for file: $FILEP00."
            $COPY = Copy-File -Source $FILEP00 -Destination $FILEP01
            
            if ($COPY -like 0) {
                Write-Log "Successfully copied $FILEP00 to $FILEP01"
                Write-Host "Successfully copied $FILEP00 to $FILEP01"
            }
            if ($COPY -like 1) {
                Write-Log "Failed to copy $FILEP00 to $FILEP01"
                Write-Host "Failed to copy $FILEP00 to $FILEP01"
            }
            if ($COPY -like 2) {
                Write-Log "File $FILEP00 not found."
                Write-Host "File $FILEP00 not found."
            }
            $FILEP00 = $null
            $FILEP01 = $null
 
        }
    }
    Catch{
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Error: Failed to copy the file ($FILEP00) from the location ($FILEP01) : Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
            Write-Host "Error: Failed to copy the file ($FILEP00) from the location ($FILEP01) : Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
    }


#Compressing log files
Write-Log "--- Beginning zip process to compress files. ---"
Write-Host "--- Beginning zip process to compress files. ---"
Compress-Archive -LiteralPath $LocalLogPath -DestinationPath "$LocalLogPath\$ZIPFILE" -Force 
if (test-path "$LocalLogPath\$ZIPFILE") {write-log "Successfully compressed logs: "$LocalLogPath\$ZIPFILE"."}else{write-log "Failed to compress logs: "$LocalLogPath\$ZIPFILE"."}
if (test-path "$LocalLogPath\$ZIPFILE") {write-host "Successfully compressed logs: "$LocalLogPath\$ZIPFILE"."}else{write-host "Failed to compress logs: "$LocalLogPath\$ZIPFILE"."}


If ($network -eq "true") {
    #Test Net Connection
    Write-Log "--- Testing Connectivity to $BasePath. ---"
    $connectTest = Test-Path $BasePath
    if (!($connectTest)) {
        Write-Log "Failed to connect to $BasePath. Skipping network file copy."
        $network = "false"
    }else{
        Write-Log "Successfull connection to $BasePath."
    }
}

If ($network -eq "true") {

    #Creating network folder for user and date
    Write-Log "--- Creating network directory for user ---"
    if (!(test-path $WinLogPath)) {New-Item -ItemType Directory -Path $WinLogPath}
    if (test-path $WinLogPath) {write-log "Successfully created $WinLogPath."}else{write-log "Failed to create $WinLogPath."}

    #Copying Log Files to network share
    Write-Log "--- Beginning the network file copy process ---"

    Write-Host "Copying file: "$LocalLogPath\$ZIPFILE"."
    Write-Log "Copying file: "$LocalLogPath\$ZIPFILE"."
    Copy-Item "$LocalLogPath\$ZIPFILE" $WinLogPath -Force
    if (test-path "$WinLogPath\$ZIPFILE") {write-log "Successfully copied $WinLogPath\$ZIPFILE."}else{write-log "Failed to copy $WinLogPath\$ZIPFILE."}
}


Write-RegKey "HKLM:\SOFTWARE\CHOA" "LogGather" "DWord" "1"
Write-RegKey "HKLM:\SOFTWARE\CHOA" "LastLogGather" "String" $SDATE
Write-RegKey "HKLM:\SOFTWARE\CHOA" "LogGatherNetworkCopy" "String" $network


Copy-Item -Path $FULLLOGPATH -Destination $WinLogPath -Force
