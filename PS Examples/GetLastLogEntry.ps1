$setupLogDir = "C:\Windows\ccmsetup\Logs"
$setupLog = "ccmsetup.log"
$evalLog = "ccmsetup-ccmeval.log"
$cName = $env:COMPUTERNAME

#$logFiles = get-childitem $setupLogDir

$lastMessage = get-content "$setupLogDir\$evallog" -Tail 1

Start-Sleep (Get-Random 60)

Write-Output "$cName, $lastMessage" | Out-File \\choa-cifs\install\WindowsLogs\CMAegntRepair\results.csv -Append -Force