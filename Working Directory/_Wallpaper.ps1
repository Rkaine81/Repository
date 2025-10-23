
$currentWallpaper = "C:\Windows\Web\Wallpaper\CHOA\CHOA_Lockscreen2.jpg"

if (!(Test-Path "C:\Windows\Web\Wallpaper\CHOA\CHOA_Lockscreen2.jpg")) {return $false}

$regPath = "HKLM:\Software\Policies\Microsoft\Windows\Personalization"
$lockScreenImagePath = Get-ItemProperty -Path $regPath -Name LockScreenImage
$lockScreenImagePath.LockScreenImage

If (($lockScreenImagePath.LockScreenImage) -ne $currentWallpaper) {
    return $false
}else{
    return $true
}