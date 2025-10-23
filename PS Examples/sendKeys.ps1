#Start-Sleep -Seconds 3000

#start-process "C:\Program Files\WindowsApps\MSTeams_25060.205.3499.6849_x64__8wekyb3d8bbwe\ms-teams.exe"

$x = 1

do {

start-sleep -Seconds 5
[System.Windows.Forms.SendKeys]::SendWait('+{F15}')
start-sleep -Seconds 55
$x = $x+1
#write-output $X
}

While ($x -lt 150)




