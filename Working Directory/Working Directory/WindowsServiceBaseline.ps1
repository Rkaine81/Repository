

#  Service Control Manager,  Token Broker,  Windows Automatic Update Service, Windows Update Medic Service

#Service / StartupType
$WindowsServices=@(
@("BITS", "Manual"),                       #Background Intelligent Transfer Service
@("BrokerInfrastructure", "Automatic"),    #Background Tasks Infrastructure Service
@("PeerDistSvc", "Manual"),                #BranchCache
@("smstsmgr", "Manual"),                   #ConfigMgr Task Sequence Agent
@("CryptSvc", "Automatic"),                #Cryptographic Services
@("DcomLaunch", "Automatic"),              #DCOM Server Process Launcher
@("DoSvc", "Manual"),                      #Delivery Optimization
@("DeviceInstall", "Manual"),              #Device Install Service
@("DsmSvc", "Manual"),                     #Device Setup Manager
@("wlidsvc", "Manual"),                    #Microsoft Account Sign-in Assistant
@("swprv", "Manual"),                      #Microsoft Software Shadow Copy Provider
@("RpcSs", "Automatic"),                   #Remote Procedure Call (RPC)
@("RpcLocator", "Manual"),                 #Remote Procedure Call (RPC) Locator
@("RpcEptMapper", "Automatic"),            #RPC Endpoint Mapper
@("CcmExec", "Automatic"),                 #SMS Agent Host
@("Schedule", "Automatic"),                #Task Scheduler
@("UsoSvc", "Automatic"),                  #Update Orchestrator Service
@("VSS", "Manual"),                        #Volume Shadow Copy
@("LicenseManager", "Manual"),             #Windows License Manager Service
@("Winmgmt", "Automatic"),                 #Windows Management Instrumentation
@("WManSvc", "Manual"),                    #Windows Management Service
@("SDRSVC", "Manual"),                     #Windows Backup
@("mpssvc", "Automatic"),                  #Background Intelligent Transfer Service
@("TrustedInstaller", "Manual"),           #Windows Modules Installer
@("WpnService", "Automatic"),              #Windows Push Notifications System Service
@("SecurityHealthService", "Manual"),      #Windows Security Service
@("W32Time", "Manual"),                    #Windows Time
@("wuauserv", "Manual"))                   #Windows Update

Try {

    $Counter=0
    foreach ($WindowsService in $WindowsServices) {
    
        $SERVICENAMETOCHECK = $WindowsService[0]
        $SERVICESTARTUPTYPE = $WindowsService[1]
        $serviceObj = Get-Service -Name $SERVICENAMETOCHECK

        if (($serviceObj.StartType) -eq "Disabled") { 
            $Counter+=1
            #Set-Service -Name $SERVICENAME -StartupType $STARTTYPE
        }
        
    }
}

Catch {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    $FullMessage = $Error[0].Exception.GetType().FullName
    Write-output "Modifying the service failed: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
}

if($Counter -eq 0) { Write-Output $true }
else { Write-Output $false }