$localPath = "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WMI\WMI-Module.psm1"

if (!(Test-Path $localPath)) {
    return $false
}else{
    return $true
}





$modeulFile = "\\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\CHOAWMIClass\WMI-Module.psm1"
$localPath = "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WMI\WMI-Module.psm1"

if (!(Test-Path $modeulFile)) {
    return $false
}

if (!(Test-Path $localPath)) {
    if (!(test-path "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WMI")) {
        new-item -ItemType Directory -Path "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WMI" -Force
        Copy-Item $modeulFile $localPath -Force
    }
}