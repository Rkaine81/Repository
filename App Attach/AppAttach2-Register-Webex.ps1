#MSIX app attach registration sample

#region variables
$packageName = "Webex_1.0.0.0_x64__j9v9wynv1mrqp"
$path = "C:\Program Files\WindowsApps\" + $packageName + "\AppxManifest.xml"
#endregion

#region register
Add-AppxPackage -Path $path -DisableDevelopmentMode -Register
#endregion