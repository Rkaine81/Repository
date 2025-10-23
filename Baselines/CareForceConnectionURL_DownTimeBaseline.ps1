#Check
$localFilePath = "C:\Users\Public\Desktop\Login - Down Time Portal.url"
if (Test-Path $localFilePath) {
    return $true
}else{
    return $false
}

#Remediation
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\Public\Desktop\Login - Down Time Portal.url")
$Shortcut.TargetPath = "https://downtime.choa.org/"
$Shortcut.Save()
