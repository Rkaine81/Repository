$DATFILE = "C:\usgdat\DirectPCUserCompliance.dat"
$DATE = get-date

$DUser = get-localuser -Name "DirectPCUser"

if ($DUser -eq $null) {

    $DATE = get-date
    Write-Output "$DATE - The DirectPCUser Account was not found." | out-file $DATFILE -Append -Force -NoClobber

    }else{

    $DATE = get-date
    Write-Output "$DATE - The DirectPCUser Account was found. Attempting to remove." | out-file $DATFILE -Append -Force -NoClobber

    Remove-LocalUser -Name "DirectPCUser"

    $DUser1 = get-localuser -Name "DirectPCUser"

        if ($DUser1 -eq $null) {
            
            $DATE = get-date
            Write-Output "$DATE - The DirectPCUser Account was successfully removed." | out-file $DATFILE -Append -Force -NoClobber
            
            }else{

            Write-Output "$DATE - The DirectPCUser Account could not be removed." | out-file $DATFILE -Append -Force -NoClobber
        }

}