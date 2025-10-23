<#

@echo off
cls
taskkill /F /IM wfcrun32.exe
taskkill /F /IM SelfServicePlugin.exe
taskkill /F /IM redirector.exe
taskkill /F /IM AnalyticsSrv.exe
taskkill /F /IM Receiver.exe
cls
echo Uninstalling Citrix....
"\\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\Citrix\WorkspaceApp\_CurrentVersion\Source\CitrixWorkspaceApp.exe" /uninstall /silent
cls
echo Reinstalling Citrix...
"\\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\Citrix\WorkspaceApp\_CurrentVersion\Source\CitrixWorkspaceApp.exe" /silent /noreboot /EnableCEIP=false /includeSSON /ALLOWADDSTORE=N /AutoUpdateCheck=disabled /AutoUpdateStream=LTSR ADDLOCAL=ReceiverInside,ICA_Client,WebHelper,SSON,AM,DesktopViewer,Flash,Vd3d,WebHelper,SELFSERVICE ALLOWADDSTORE=N ENABLE_DYNAMIC_CLIENT_NAME=Yes ENABLE_SSON=Yes

reg import "%~dp0Unblock.reg"
cls
echo Citrix Reinstalled!
echo (PLEASE RESTART)
echo.
TIMEOUT /T 10

#>

#Citrix Health Check



# Function to check if a service is running
function Check-ServiceRunning($serviceName) {
    try {
        $service = Get-Service -Name $serviceName -ErrorAction Stop
        if ($service.Status -eq 'Running') {
            return "Running"
        } else {
            return "Stopped"
        }
    } catch {
        return "Failed"
    }
}


function Check-CitrixProcesses($processName) {
    # Function to check if a Process is running
    function Check-ProcessRunning($processName) {
        try {
            $process = $null
            $process = Get-Process -Name $processName -ErrorAction Stop
            if ($null -eq $sprocess) {
                return "Running"
            } else {
                return "Stopped"
            }
        } catch {
            return "Failed"
        }
    }

    $results = @()
    $CitrixProcesses = "wfcrun32",
    "SelfServicePlugin",
    "explorer",
    "redirector",
    "AnalyticsSrv",
    "Receiver"

    foreach ($cProcess in $CitrixProcesses) {
        # Gather all results into a single PSObject
        $citrixProcessesObj = [PSCustomObject]@{
            Name   = $cProcess
            Status = Check-ProcessRunning $cProcess
            Type = "Process"
        }
        $results += $citrixProcessesObj
    }
    return $results
}



# Citrix Processes
$citrixProcessObject = Check-CitrixProcesses
$citrixProcessObject

#Citrix Service
$citrixService = "CWAUpdaterService"
$citrixServiceObj = [PSCustomObject]@{
    Name   = $citrixService
    Status = Check-ServiceRunning -serviceName $citrixService
    Type = "Service"
}
$citrixServiceObj