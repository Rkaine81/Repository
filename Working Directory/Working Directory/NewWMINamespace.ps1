if (!(Test-path "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WMI\WMI-Commands.psm1")) {
    $modeulFile = "\\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\CHOAWMIClass\WMI-Commands.psm1"
    $localPath = "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WMI\WMI-Commands.psm1"

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

if (Test-path "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WMI\WMI-Commands.psm1") {
    Import-Module C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WMI\WMI-Commands.psm1
}else{
    return $false
}



$namespaceName = "CHOA_NameSpace"
$className = "CHOA_Module_Test"

New-WMINameSpace -NameSpace $namespaceName

New-WMIClass -ClassName $className


New-WMIProperty -ClassName $className -PropertyName "Total" -PropertyValue $errorCount.ToString()




# Remove-WMIClass -ClassName $className -Force