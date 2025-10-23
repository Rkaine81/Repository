

#  Service Control Manager,  Token Broker,  Windows Automatic Update Service, Windows Update Medic Service

#Service / StartupType
$WindowsServices=@(
@("CiscoOrbital", "Automatic"),            #Cisco AMP Orbital
@("csc_vpnagent", "Automatic"),            #Cisco Secure Client - AnyConnect VPN Agent
@("CiscoCloudManagement", "Automatic"),    #Cisco Secure Client - Cloud Management
@("csc_umbrellaagent", "Manual"),          #Cisco Secure Client - Umbrella Agent
@("csc_swgagent", "Manual"),               #Cisco Secure Client - Umbrella SWG Agent
@("CiscoAMP", "Automatic"),                #Cisco Secure Endpoint 8.2.4
@("CiscoSCMS", "Automatic"))               #Cisco Security Connector Monitoring 8.2.4



#Cisco Security Connector Monitoring 8.2.4
$serviceName = "CiscoSCMS"
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



#Cisco Security Connector Monitoring 8.2.4
$serviceName = "CiscoSCMS"
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

