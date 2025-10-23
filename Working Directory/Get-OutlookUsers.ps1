Add-Content -Path "C:\Temp\Outlook Classic\Outlook Classic Users.csv" "Email Address,User ID,Last Name,First Name"  
foreach ($a in (Get-Content -Path "C:\Temp\Outlook Classic\Outlook Classic Users.txt")) {
    $b = Get-ADUser $a
    Add-Content -Path "C:\Temp\Outlook Classic\Outlook Classic Users.csv" "$($b.userPrincipalName),$($b.samAccountName),$($b.Name)"  
}
