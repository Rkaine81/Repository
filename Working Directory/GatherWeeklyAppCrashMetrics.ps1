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


$className = "CHOA_DEX_APPCRASH"
$DAYS = "00", "01", "02", "03", "04", "05", "06"
$errorCount = 0


New-WMIClass -ClassName $className


foreach ($DAY in $DAYS) {
    $regPath = "HKLM:\SOFTWARE\CHOA\DEX\APPCRASH\$DAY"
    $dailyObjs = Get-Item $regPath
    $dailyEntries = ($dailyObjs.Property)
    foreach ($dailyEntry in $dailyEntries) {
        $dailyRegPath =  "$regPath\$dailyEntry"
        $dailyErrorCount = Get-ItemPropertyValue $regPath $dailyEntry
        $errorCount = $errorCount + $dailyErrorCount
        #write-output "The daliy error count is: $errorCount"
    }
    write-output "On day $DAY, there were $errorCount app crashes."
    #$errorCount
    $dayName = switch ($DAY)
    {
        "00" {"Sunday"}
        "01" {"Monday"}
        "02" {"Tuesday"}
        "03" {"Wednesday"}
        "04" {"Thursday"}
        "05" {"Friday"}
        "06" {"Saturday"}
    }
    New-WMIProperty -ClassName $className -PropertyName $dayName -PropertyValue $dailyErrorCount.ToString()
}
$errorCount
New-WMIProperty -ClassName $className -PropertyName "Total" -PropertyValue $errorCount.ToString()

# Remove-WMIClass -ClassName $className -Force