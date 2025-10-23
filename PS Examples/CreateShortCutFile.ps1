$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\Public\Desktop\Login - Nuance Powerscribe 360.url")
$Shortcut.TargetPath = "C:\windows\system32\rundll32.exe dfshim.dll, ShOpenVerbApplication https://ps360v4.choa.org/PS360ReportingClient/Client/Nuance.PowerScribe360.application"
#$Shortcut.TargetPath = "https://ps360v4.choa.org/PS360ReportingClient/Client/Nuance.PowerScribe360.application"
$Shortcut.Save()