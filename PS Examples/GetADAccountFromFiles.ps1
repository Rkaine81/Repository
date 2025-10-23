$names = Import-Csv -Path "C:\Users\179944\OneDrive - CHOA\CurrentChannelUsers.csv" -Header First, Last


foreach ($entry in $names) {

    $last = $entry.Last
    $first = $entry.First
    $surnameMatch =Get-ADUser -Filter "Surname -eq '$($last)'"

    foreach ($ObjUser in $surnameMatch) {
        if (($ObjUser.GivenName) -eq $first -and ($ObjUser.GivenName) -notlike "*(SA)" -and ($ObjUser.Enabled) -eq "True") {
            $actualUser = $ObjUser
        }
    }

    $actualUser.SamAccountName

}



