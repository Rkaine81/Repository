$ADMembers = Get-ADGroupMember "APG-WVD_General-East_UserAccess"
$ADMembers.count
foreach ($ADMember in $ADMembers) {
    Write-Output ($($ADMember.SamAccountName)) | out-file "C:\Users\206676599\OneDrive - NBCUniversal\Temp\WVDEast2.txt.txt" -Append -force
}


$group = "domain users"
$Users = Get-ADGroup $group -Properties Member | Select-Object -Expandproperty Member| Get-ADUser
$users.samaccountname.Count | out-file "C:\Users\206676599\OneDrive - NBCUniversal\Temp\WVDEast3.txt" -Append -force


$adam = Get-ADUser -Identity 206052457 -Properties  HomeDirectory, HomeDrive | Select Name, SamAccountName, HomeDirectory, HomeDrive

Get-ADUser -Filter 'enabled -eq $true' -Properties HomeDirectory | Select Name, HomeDirectory | Out-File C:\TEMP\UserHomePath.csv

Get-ADUser -Filter 'enabled -eq $true' -Properties HomeDirectory | Select Name, HomeDirectory | Export-Csv -path "C:\TEMP\ADUserHomePath.csv"