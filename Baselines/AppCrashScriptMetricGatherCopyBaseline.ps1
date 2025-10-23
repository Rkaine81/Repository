$localScripts = "C:\Apps\Dex\GatherWeeklyAppCrashMetrics.ps1",
"C:\Apps\Dex\HourlyAppCreashMetricsRegistry.ps1"
$x = 0
foreach ($localScript in $localScripts) {
    $check = Test-Path $localScript
    if ($check -eq $false) {
        $x = $x + 1
    }
}

$dexDir = "C:\Apps\Dex"
$scripts = "\\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\DEX\APPCRASH\GatherWeeklyAppCrashMetrics.ps1",
"\\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\DEX\APPCRASH\HourlyAppCreashMetricsRegistry.ps1"
$scriptDir = "\\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\DEX\APPCRASH"

if (!(Test-Path -Path $dexDir)) { new-item -ItemType Directory $dexDir }

if (!(Test-Path -Path $scriptDir)) { return $false }

foreach ($script in $scripts) {
    $scriptName = $script.split('\')[-1]
    if (test-path -Path "$dexDir\$scriptName") {
        if ((Get-Item $script).LastWriteTime -gt (get-item ("$dexDir\$scriptName")).LastWriteTime) {
            $x = $x + 1
        }
    }
}

if ($x -eq 0) {
    return $true
}else{
    return $false
}




$dexDir = "C:\Apps\Dex"
$scripts = "\\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\DEX\APPCRASH\GatherWeeklyAppCrashMetrics.ps1",
"\\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\DEX\APPCRASH\HourlyAppCreashMetricsRegistry.ps1"
$scriptDir = "\\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\DEX\APPCRASH"

if (!(Test-Path -Path $dexDir)) { new-item -ItemType Directory $dexDir }

if (!(Test-Path -Path $scriptDir)) { return $false }

foreach ($script in $scripts) {
    $scriptName = $script.split('\')[-1]
    if (test-path -Path "$dexDir\$scriptName") {
        if ((Get-Item $script).LastWriteTime -gt (get-item ("$dexDir\$scriptName")).LastWriteTime) {
            Copy-Item $script $dexDir -Force
        }
    }
}