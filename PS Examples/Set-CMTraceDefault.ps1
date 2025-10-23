# Create .Log and .Lo_ Keys to make CMTrace.exe the Default Log Viewer
New-Item -Path HKLM:\SOFTWARE\Classes\.lo_ -Value "Log.File" -Force -ErrorAction SilentlyContinue
New-Item -Path HKLM:\SOFTWARE\Classes\.log -Value "Log.File" -Force -ErrorAction SilentlyContinue
New-Item -Path HKLM:\SOFTWARE\Classes\Log.File\shell\open\command -Value "`"C:\Windows\CCM\CMTrace.exe`" `"%1`"" -Force -ErrorAction SilentlyContinue

#Create ActiveSetup to remove CMTrace question if it should be the Default Log Reader
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\CMtrace" -Force -ErrorAction SilentlyContinue
New-ItemProperty "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\CMtrace" -Name "Version" -Value 1 -PropertyType String -Force -ErrorAction SilentlyContinue
New-ItemProperty "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\CMtrace" -Name "StubPath" -Value "reg.exe ADD HKCU\Software\Microsoft\Trace32 /v ""Register File Types"" /d 0 /f" -PropertyType ExpandString -Force -ErrorAction SilentlyContinue