if (Test-path "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WMI\WMI-Module.psm1") {

    Import-Module C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WMI\WMI-Module.psm1

    $choaWMIClass = Get-WMIClass -ClassName "CHOA_Monitors"
    if (($choaWMIClass.Name) -eq "CHOA_Monitors") {
        return $true
    }else{
        return $false
    }
}else{
    return $false
}