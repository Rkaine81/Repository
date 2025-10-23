$driveLetter = Read-Host 'Enter USB drive (Example: F:)'

If (-not ($driveLetter.EndsWith(':'))) { $driveLetter = $driveLetter + ':' }

If ( (Get-WmiObject Win32_LogicalDisk -Filter "Name = '$driveLetter'").Description -ne 'Removable Disk') {

    Write-Host 'Bad drive, try again.' -ForegroundColor Red
}

Else { Write-Host 'Do something here' }




$DISK = Get-WmiObject Win32_LogicalDisk
foreach ($obj in $DISK){
$obj.DeviceID + " " + $obj.VolumeName
}
