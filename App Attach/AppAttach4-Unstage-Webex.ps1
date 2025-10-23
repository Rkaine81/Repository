#MSIX app attach de staging sample

$vhdSrc="\\eclapwp00555\MSIX\MSIX_AppAttach\Webex.vhdx"

#region variables
$packageName = "Webex_1.0.0.0_x64__j9v9wynv1mrqp"
$msixJunction = "C:\temp\AppAttach"
#endregion

#region deregister
Remove-AppxPackage -AllUsers -Package $packageName
Remove-Item "$msixJunction\$packageName" -Recurse -Force -Verbose
#endregion

#region Detach VHD
Dismount-DiskImage -ImagePath $vhdSrc -Confirm:$false
#endregion