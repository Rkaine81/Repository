# check if a meeting is in progress:
$jsonFilePath = "C:\Andor Health\Rounding Device\Preferences.json"
$jsonContent = Get-Content -Path $jsonFilePath -Raw
$jsonObject = $jsonContent | ConvertFrom-Json
$isMeetingUrlValid = $jsonObject.MeetingUrl -and -not [string]::IsNullOrWhiteSpace($jsonObject.MeetingUrl)

do {
    start-sleep 10
    
    $jsonContent = Get-Content -Path $jsonFilePath -Raw
    $jsonObject = $jsonContent | ConvertFrom-Json
    $isMeetingUrlValid = $jsonObject.MeetingUrl -and -not [string]::IsNullOrWhiteSpace($jsonObject.MeetingUrl)

}
while ($isMeetingUrlValid) 

& cmd.exe /c shutdown /r /t 60