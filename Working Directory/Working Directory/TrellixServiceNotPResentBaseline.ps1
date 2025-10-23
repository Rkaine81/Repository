

#  Service Control Manager,  Token Broker,  Windows Automatic Update Service, Windows Update Medic Service

#Service / StartupType
$WindowsServices=@(
@("McAfeeFramework", "Manual"),            #Trellix Agent Backwards Compatibility Service
@("macmnsvc", "Automatic"),                #Trellix Agent Common Services
@("masvc", "Automatic"),                   #Trellix Agent Service
@("TrellixDLPAgentService", "Automatic"),  #Trellix DLP Endpoint Service
@("MfeFfCoreService", "Automatic"),        #Trellix FRP Core Service
@("Trellix Management of Native Encryption Service", "Automatic"))  #Trellix Management of Native Encryption Service



#Trellix Management of Native Encryption Service
$serviceName = "Trellix Management of Native Encryption Service"
$serviceStartType = "Automatic"
$serviceStatus = "Running"

$serviceObj = Get-Service -Name $serviceName

if ($null -eq $serviceObj) {
    return $false
}else{
    if ($serviceObj.StartType -ne $serviceStartType) {
        return $false
    }else{
        if ($serviceObj.Status -ne $serviceStatus) {
            return $false
        }else{
            return $true
        }
    }
}




#Trellix Management of Native Encryption Service
$serviceName = "Trellix Management of Native Encryption Service"
$serviceStartType = "Automatic"
$serviceStatus = "Running"

$serviceObj = Get-Service -Name $serviceName

if ($null -eq $serviceObj) {
    return $false
}else{
    if ($serviceObj.StartType -ne $serviceStartType) {
        Set-Service -Name $serviceName -StartupType $serviceStartType
    }
    if ($serviceObj.Status -ne $serviceStatus) {
        Set-Service -Name $serviceName -Status $serviceStatus
    }
}
