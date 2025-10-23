$membersList = "BUILTIN\Administrators",
"CHOA\Domain Admins",
"CHOA\RadISAdmins",
"CHOA\RemoteControl",
"CHOA\SCCM_CAP",
"CHOA\SCCMService"


$adGroupName = "ConfigMgr Remote Control Users"

$cmRemoteGroup = Get-LocalGroup -Name $adGroupName

if ($null -eq $cmRemoteGroup) {
    Return $false
}

$groupMembers = Get-LocalGroupMember -Name ($cmRemoteGroup.Name)

$missingCount = 0

foreach ($member in $membersList) {
    if (!(($groupMembers.Name) -contains ($member))) {
        $missingCount ++
    }
}

if ($missingCount -gt 0) {
    return $false
}else{
    return $true
}