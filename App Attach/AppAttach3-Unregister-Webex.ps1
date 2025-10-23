#MSIX app attach deregistration sample

#region variables
$packageName = "Webex_1.0.0.0_x64__j9v9wynv1mrqp"
#endregion

#region deregister
Remove-AppxPackage -PreserveRoamableApplicationData $packageName
#endregion