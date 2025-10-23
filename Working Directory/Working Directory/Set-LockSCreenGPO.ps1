

# Set your variables
$gpoName = "WS_Visual_Messaging_Automation_Test"
$newLockScreenImage = "C:\Windows\Web\Wallpaper\CHOA\CHOA_Lockscreen2.jpg"

# Check if GPO exists
$gpo = Get-GPO -Name $gpoName -ErrorAction Stop

# Get current values
$currentLockScreen = Get-GPRegistryValue -Name $gpoName `
   -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" `
   -ValueName "LockScreenImage" -ErrorAction SilentlyContinue
Write-Output "Current LockScreenImage: $($currentLockScreen.Value)"

# Set new Lock Screen image
Set-GPRegistryValue -Name $gpoName `
   -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" `
   -ValueName "LockScreenImage" `
   -Type String `
   -Value $newLockScreenImage
Write-Output "GPO has been updated with new Lock Screen and Logon image settings."
