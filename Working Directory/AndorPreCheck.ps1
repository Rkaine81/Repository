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


If (Get-Process -Name "Rounding.WPF") { Get-Process -Name "Rounding.WPF" | Stop-Process -Force -PassThru }

if (Get-Process -Name "Rounding.WPF") {
    Write-Output "Rounding.WPF Andor process is still running."
    Exit 1
}Else{
    Write-Output "Rounding.WPF Andor process was not found running."
    New-Item -Path C:\CHOA -Name "AndorPreCheck.tag" -Force
    Exit 0
}

