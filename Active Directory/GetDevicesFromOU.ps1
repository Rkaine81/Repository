$Computers1 = Get-ADComputer -Filter * -SearchBase "OU=Desktop,OU=US-USH-WVD,OU=Computers,DC=TFAYD,DC=com"

Write-Output "OU=Desktop,OU=US-USH-WVD,OU=Computers,DC=TFAYD,DC=com" | out-file D:\temp\WVD_PCs_to_Delete.txt -Force -Append -NoClobber

foreach ($Computer1 in $Computers1) {

    if (($Computer1.Name) -notlike "wvdp-0223*") {

        Write-Output $($Computer1.Name) | out-file D:\temp\WVD_PCs_to_Delete.txt -Force -Append -NoClobber

    }

}

Write-Output "" | out-file D:\temp\WVD_PCs_to_Delete.txt -Force -Append -NoClobber

$Computers2 = Get-ADComputer -Filter * -SearchBase "OU=Desktop,OU=US-ASH-WVD,OU=Computers,DC=TFAYD,DC=com"

Write-Output "OU=Desktop,OU=US-ASH-WVD,OU=Computers,DC=TFAYD,DC=com" | out-file D:\temp\WVD_PCs_to_Delete.txt -Force -Append -NoClobber

foreach ($Computer2 in $Computers2) {

    if (($Computer2.Name) -notlike "wvdp-0223*") {

        Write-Output $($Computer2.Name) | out-file D:\temp\WVD_PCs_to_Delete.txt -Force -Append -NoClobber

    }

}
