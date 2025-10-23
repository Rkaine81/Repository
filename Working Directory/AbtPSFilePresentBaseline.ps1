
$x=0
if (!(test-path C:\Apps\AbtPS)) {$x = $x + 1}
if (!(test-path C:\Apps\AbtPS\HP)) {$x = $x + 1}
if (!(test-path C:\Apps\AbtPS\HP\CmpTrWmi_2.0)) {$x = $x + 1}
if (!(test-path C:\Apps\AbtPS\HP\CmpTrWmi_3.0)) {$x = $x + 1}
if (!(test-path C:\Apps\AbtPS\HP\CmpTrWmi_3.0_64)) {$x = $x + 1}
if (!(test-path C:\Apps\AbtPS\AbtPaaSTest.dll)) {$x = $x + 1}
if (!(test-path C:\Apps\AbtPS\AbtPersStatusReport.dll)) {$x = $x + 1}
if (!(test-path C:\Apps\AbtPS\AbtPersStatusReport64.dll)) {$x = $x + 1}
if (!(test-path C:\Apps\AbtPS\AbtPS.exe)) {$x = $x + 1}
if (!(test-path C:\Apps\AbtPS\readme.txt)) {$x = $x + 1}
if (!(test-path C:\Apps\AbtPS\HP\CmpTrWmi_2.0\CmpTrWmi.dll)) {$x = $x + 1}
if (!(test-path C:\Apps\AbtPS\HP\CmpTrWmi_3.0\CmpTrWmi.dll)) {$x = $x + 1}
if (!(test-path C:\Apps\AbtPS\HP\CmpTrWmi_3.0_64\CmpTrWmi.dll)) {$x = $x + 1}
if (!(test-path C:\Apps\AbtPS\HP\CmpTrWmi_3.0_64\CmpTrWmi64.dll)) {$x = $x + 1}
if ($x -eq 0) {
    return $true
}else{
    return $false
}
