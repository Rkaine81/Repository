# Begin Module baseline

$localPath = "C:\Program Files\WindowsPowerShell\Modules\MSIPatches"

if (!(Test-Path $localPath)) {
    return $false
}else{
    return $true
}



$modeulFile = "\\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\PSModules\MSIPatches"
$localPath = "C:\Program Files\WindowsPowerShell\Modules\MSIPatches"

if (!(Test-Path $modeulFile)) {
    return $false
}


if (!(test-path $localPath)) {
    Copy-Item $modeulFile $localPath -Force -Recurse
}

# End Module Baseline




# Begin Orphaned Patch Count

import-module MSIPatches
$count = get-msipatch
$count.OrphanedPatchSize

# End Orphaned Patch Count




# Begin Orphaned patch Baseline

import-module MSIPatches
$count = get-msipatch
if (($count.OrphanedPatchCount) -eq 0) {
    return $true
}else{
    return $false
}


import-module MSIPatches
$orphaned = Get-OrphanedPatch
foreach ($patch in $orphaned) {
    remove-item $patch -Force
}

# End Orphaned patch Baseline