$serviceName = "QualysAgent"
$serviceStartType = "Automatic"
$serviceStatus = "Running"

$counter = 0

$serviceObj = Get-Service -Name  $serviceName -ErrorAction SilentlyContinue

if (($serviceObj.Name) -eq  $serviceName) {

    if (!(($serviceObj.StartType) -eq $serviceStartType)) {
        $Counter+=1
    }else{
        
    }

    if (!(($serviceObj.Status) -eq $serviceStatus)) {
        $Counter+=1
    }else{
        
    }
}else{
    $Counter+=1
}

if ($counter -eq 0) {
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