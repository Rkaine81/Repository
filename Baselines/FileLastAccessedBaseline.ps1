#CfgItem Registry Value Exists
$filePath = "C:\Windows\System32\GroupPolicy\Machine\registry.pol"

if (Test-Path $filePath) {
    $registryPOL  = Get-Item -Path $filePath
    $lastWriteTime = $registryPOL.LastWriteTime
    $today = (get-date)
    $tooOld = ($today.AddDays(-30))
    If ($lastWriteTime -le $tooOld) {
        return $false
    }else{
        return $true
    }
}