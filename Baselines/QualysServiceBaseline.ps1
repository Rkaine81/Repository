$serviceName = "QualysAgent"

$serviceObj = Get-Service -Name  $serviceName -ErrorAction SilentlyContinue

if (!($null -eq $serviceObj)) {
    return $true
}else{
    return $false
}



$serviceName = "QualysAgent"
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