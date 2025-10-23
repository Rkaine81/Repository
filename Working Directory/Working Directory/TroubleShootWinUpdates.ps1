function Show-Menu {
   param (
       [string]$Title = 'Windows Update Troubleshooting Menu'
   )
   Clear-Host
   Write-Host "================ $Title ================"
   Write-Host "1: Press '1' to list update history."
   Write-Host "2: Press '2' to check for new updates."
   Write-Host "3: Press '3' to reset Windows Update components."
   Write-Host "4: Press '4' to view detailed information about failed updates."
   Write-Host "5: Press '5' to clear the Windows Update download cache."
   Write-Host "6: Press '6' to run the Windows Update troubleshooter."
   Write-Host "7: Press '7' to restore Windows Update services to default."
   Write-Host "8: Press '8' to display SURT results."
   Write-Host "9: Press '9' to enable verbose logging for Windows Update."
   Write-Host "A: Press 'A' to check and repair system file integrity."
   Write-Host "Q: Press 'Q' to quit."
}
# Helper Functions
function Get-UpdateHistory {
   Get-HotFix
}
function Check-ForUpdates {
   $UpdateSession = New-Object -ComObject Microsoft.Update.Session
   $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
   $SearchResult = $UpdateSearcher.Search("IsInstalled=0")
   $SearchResult.Updates | Select-Object -Property Title, Description, IsDownloaded, IsInstalled
}
function Reset-WindowsUpdate {
   Write-Host "Stopping Windows Update services..."
   Stop-Service wuauserv, bits, appidsvc, cryptsvc -Force
   Write-Host "Deleting cache files..."
   Remove-Item "$env:windir\SoftwareDistribution\*" -Recurse -Force
   Remove-Item "$env:windir\System32\catroot2\*" -Recurse -Force
   Write-Host "Restarting Windows Update services..."
   Start-Service wuauserv, bits, appidsvc, cryptsvc
   Write-Host "Windows Update components have been reset."
}
function Get-FailedUpdates {
   $UpdateSession = New-Object -ComObject Microsoft.Update.Session
   $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
   $SearchResult = $UpdateSearcher.Search("IsInstalled=0 and Type='Software'")
   $FailedUpdates = $SearchResult.Updates | Where-Object {$_.InstallationBehavior.CanRequestUserInput}
   $FailedUpdates | Select-Object -Property Title, Description, LastDeploymentChangeTime
}
function Clear-UpdateCache {
   Stop-Service wuauserv -Force
   Remove-Item "$env:windir\SoftwareDistribution\Download\*" -Recurse -Force
   Start-Service wuauserv
   Write-Host "Windows Update download cache has been cleared."
}
function Run-Troubleshooter {
   msdt.exe /id WindowsUpdateDiagnostic
}
function Restore-WindowsUpdateDefaults {
   Set-Service wuauserv -StartupType Automatic
   Set-Service bits -StartupType Automatic
   Set-Service appidsvc -StartupType Manual
   Set-Service cryptsvc -StartupType Automatic
   Write-Host "Windows Update services restored to default settings."
}
function Display-SURTResults {
   Write-Host "Checking System Update Readiness Tool results..."
   Get-Content "$env:windir\Logs\CBS\CheckSUR.log"
}
function Enable-VerboseLogging {
   $RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Trace"
   Set-ItemProperty -Path $RegistryPath -Name "Flags" -Value "0xFFFF"
   Set-ItemProperty -Path $RegistryPath -Name "Level" -Value "0x200"
   Write-Host "Verbose logging enabled for Windows Update."
}
function Check-RepairSystemFiles {
   Write-Host "Running System File Checker..."
   sfc /scannow
}

# Main Loop
do {
   Show-Menu
   $input = Read-Host "Please make a selection"
   switch ($input) {
       '1' { Get-UpdateHistory | Out-Host }
       '2' { Check-ForUpdates | Out-Host }
       '3' { Reset-WindowsUpdate }
       '4' { Get-FailedUpdates | Out-Host }
       '5' { Clear-UpdateCache }
       '6' { Run-Troubleshooter }
       '7' { Restore-WindowsUpdateDefaults }
       '8' { Display-SURTResults }
       '9' { Enable-VerboseLogging }
       'A' { Check-RepairSystemFiles }
       'Q' { return }
       default { Write-Host "Invalid option, please try again." }
   }
   pause
}
while ($input -ne 'Q')