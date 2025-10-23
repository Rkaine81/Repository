while (1 -ne 2) {
    $var = Get-Random -Minimum 4 -Maximum 9
    if ($var -eq 8){
        Write-Output "It outputted an 8."
        exit 0
        }else{
        write-output "Not 8"
        }


    }