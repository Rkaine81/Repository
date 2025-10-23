if (!(Test-path "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WMI\WMI-Module.psm1")) {
    $modeulFile = "\\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\CHOAWMIClass\WMI-Module.psm1"
    $localPath = "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WMI\WMI-Module.psm1"

    if (!(Test-Path $modeulFile)) {
        return $false
    }

    if (!(Test-Path $localPath)) {
        if (!(Test-Path "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WMI")) {
            New-Item -ItemType Directory -Path "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WMI" -Force
            Copy-Item $modeulFile $localPath -Force
        }
    }
}

if (Test-path "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WMI\WMI-Module.psm1") {
    Import-Module C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WMI\WMI-Module.psm1
}else{
    return $false
}



if (!(Test-Path "C:\Apps\Monitors\SL4042683514857.csv")) { return $false }

$monitors = import-csv "C:\Apps\Monitors\SL4042683514857.csv"

$className = "CHOA_Monitors2"

New-WMIClass -ClassName $className
$x = 1

foreach ($monitorObj in $monitors) {
    New-WMIProperty -ClassName $className -PropertyName ("Manufacturer" + ($x).ToString()) -PropertyValue $monitorObj.MonitorMake
    New-WMIProperty -ClassName $className -PropertyName ("Model" + ($x).ToString()) -PropertyValue $monitorObj.MonitorModel
    New-WMIProperty -ClassName $className -PropertyName ("SerialNumber" + ($x).ToString()) -PropertyValue $monitorObj.MonitorSerialNumber
    $x = $x + 1
}


# Remove-WMIClass -ClassName $className -Force