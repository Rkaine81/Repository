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


$compName = $env:COMPUTERNAME

if (!(Test-Path "C:\Apps\Monitors\$compName.csv")) { return $false }


$monitors = import-csv "C:\Apps\Monitors\$compName.csv"

$className = "CHOA_Monitors"

New-WMIClass -ClassName $className
$x = 1

foreach ($monitorObj in $monitors) {
    New-WMIProperty -ClassName $className -PropertyName ("Manufacturer" + ($x).ToString()) -PropertyValue $monitorObj.MonitorMake
    New-WMIProperty -ClassName $className -PropertyName ("Model" + ($x).ToString()) -PropertyValue $monitorObj.MonitorModel
    New-WMIProperty -ClassName $className -PropertyName ("SerialNumber" + ($x).ToString()) -PropertyValue $monitorObj.MonitorSerialNumber
    $x = $x + 1
}