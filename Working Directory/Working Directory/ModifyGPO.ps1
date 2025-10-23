# Import the GroupPolicy module
Import-Module GroupPolicy
# Variables
$GpoName = "WS_Visual_Messaging" # Replace with the name of your GPO
$LockScreenImagePath = "\\YourServer\Share\LockScreen.jpg" # Replace with your image path
# Ensure the GPO exists or create it
$Gpo = Get-Gpo -Name $GpoName -ErrorAction SilentlyContinue
if (-not $Gpo) {
   Write-Host "GPO not found. Creating a new GPO: $GpoName"
   $Gpo = New-Gpo -Name $GpoName
}
# Configure the lock screen image policy
Write-Host "Configuring the lock screen policy..."
Set-GPInheritance -Name $GpoName -Enabled $true
# Define the Policy Path and Setting
$PolicyPath = "Computer Configuration\Administrative Templates\Control Panel\Personalization"
$PolicySetting = "Force a specific default lock screen image"
# Enable the policy and set the value
Set-GPRegistryValue -Name $GpoName `
   -Key "Software\Policies\Microsoft\Windows\Personalization" `
   -ValueName "LockScreenImage" `
   -Type String `
   -Value $LockScreenImagePath
Write-Host "Lock screen image policy successfully applied to GPO: $GpoName"