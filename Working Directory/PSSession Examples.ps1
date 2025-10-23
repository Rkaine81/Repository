$hostname = "SR-CIRU-5SVBK8W"

New-PSSession -ComputerName $hostname

Enter-PSSession -ComputerName $hostname

Exit-PSSession

Get-PSSession

Disconnect-PSSession -Id 1

Remove-PSSession -Id 1

$cert = Get-ChildItem 'Cert:\LocalMachine\CA' | Where-Object{ $_.Extensions | Where-Object{ ($_.Oid.FriendlyName -eq 'Certificate Template Information') -and ($_.Format(0) -match $templateName) }}

$certstore.storenames

Get-ChildItem 'Cert:\LocalMachine\CA' | Get-Member -MemberType Properties

Get-ChildItem 'Cert:\LocalMachine\CA' |  Where-Object{ ($_.Thumbprint -eq 'd72caf0ef1a2eaf2f5fee5ccfd7428a320418418') }

$testVal = Get-ChildItem 'Cert:\LocalMachine\CA'

$testval.thumbprint


### Cert Check ###

$certCheck = Get-ChildItem 'Cert:\LocalMachine\CA' |  Where-Object{ ($_.Thumbprint -eq 'd72caf0ef1a2eaf2f5fee5ccfd7428a320418418') }


if ($null -eq $certCheck) {
    return $false
}else{
    return $true
}


$results = "Computer policy could not be updated successfully. The following errors were encountered:"

$gpResults = gpupdate /force

if ($gpResults -eq $results) {
    return $false
}else{
    return $true
}



Remove-item C:\Windows\System32\GroupPolicy -Force -Recurse
start-sleep 3
gpupdate /force