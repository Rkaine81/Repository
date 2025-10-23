

#  Service Control Manager,  Token Broker,  Windows Automatic Update Service, Windows Update Medic Service

#Service / StartupType
$WindowsServices=@(
@("McAfeeFramework", "Manual"),            #Trellix Agent Backwards Compatibility Service
@("macmnsvc", "Automatic"),                #Trellix Agent Common Services
@("masvc", "Automatic"),                   #Trellix Agent Service
@("TrellixDLPAgentService", "Automatic"),  #Trellix DLP Endpoint Service
@("MfeFfCoreService", "Automatic"),        #Trellix FRP Core Service
@("Trellix Management of Native Encryption Service", "Automatic"))  #Trellix Management of Native Encryption Service


Try {

    $Counter=0
    foreach ($WindowsService in $WindowsServices) {
    
        $SERVICENAMETOCHECK = $WindowsService[0]
        $SERVICESTARTUPTYPE = $WindowsService[1]
        $serviceObj = Get-Service -Name $SERVICENAMETOCHECK



        if (($serviceObj.Name) -eq $SERVICENAMETOCHECK) {

            if (!(($serviceObj.StartType) -eq $SERVICESTARTUPTYPE)) {
                $Counter+=1
            }else{
        
            }

            if (!(($serviceObj.Status) -eq "running")) {
                $Counter+=1
            }else{
        
            }
        }

    }
}

Catch {
    $Counter+=1
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    $FullMessage = $Error[0].Exception.GetType().FullName
    Write-output "Modifying the service failed: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
}

if($Counter -eq 0) { Write-Output $true }
else { Write-Output $false }