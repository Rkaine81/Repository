$localFilePath = "C:\Users\Public\Desktop\Sectra Downtime.url"
if (Test-Path $localFilePath) {
    return $true
}else{
    return $false
}



#change this to the CCM Cache lpocal file
#$source = "\\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\Sectra\Sectra IDS7 Shortcut\Sectra Downtime.url"
$dest = "C:\Users\Public\Desktop\Sectra Downtime.url"
#$iconPath = "C:\Windows\Web\Icons"

If (!(Test-Path "C:\Windows\Web\Icons")) {New-Item -ItemType Directory -Path C:\Windows\Web -Name Icons}

If (!(Test-Path "C:\Windows\Web\Icons\EDTFinal.ico")) {Copy-Item "EDTFinal.ico" "C:\Windows\Web\Icons\EDTFinal.ico" -Force}

If (!(test-path "C:\Users\Public\Desktop\Sectra Downtime.url")) {
    Copy-Item -Path "Sectra Downtime.url" $dest -Force
}

If (!(test-path "C:\Users\Public\Desktop\Sectra Downtime.url")) {
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("C:\Users\Public\Desktop\Sectra Downtime.url")
    $Shortcut.TargetPath = "https://imaging-edt.choa.org/ids7/"
    $Shortcut.Save()
    Write-Output "The file copy did not work."
}