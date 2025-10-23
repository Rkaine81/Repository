$users = get-content C:\choa\file.txt

foreach ($user in $Users) {
    Try 
    {
        $adUserObj = Get-ADUser -Identity $user -Properties EmailAddress
        $emailAddr = $adUserObj.EmailAddress
    }
    Catch
    {
        $emailAddr = "User Not found in AD"       
    }

    Write-Output "$user,$emailAddr" | Out-File C:\CHOA\Win11EmailAddr.csv -Force -Append
}
