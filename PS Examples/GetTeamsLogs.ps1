


$teamsLog = Get-ChildItem -Path "C:\CHOA" -Filter TeamsHealth.log -Recurse -ErrorAction SilentlyContinue -Force
$fileName = $env:COMPUTERNAME + "_TeamsHealth.log"

If (test-path "\\choa-cifs\install\WindowsLogs\TeamsHealth\$fileName") {Remove-Item "\\choa-cifs\install\WindowsLogs\TeamsHealth\$fileName" -Force}

Copy-Item ($teamsLog.FullName) "\\choa-cifs\install\WindowsLogs\TeamsHealth\$fileName"
