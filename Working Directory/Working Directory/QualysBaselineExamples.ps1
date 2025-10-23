#Output Qualys Data


$qualysHealth = & "$env:ProgramFiles\qualys\qualysagent\QualysAgentHealthCheck.exe"
$fullFilePath = ($qualysHealth | where {$_ -like "Detailed*"}).split(":")[-1]
$fullFilePath = "C:$fullFilePath"
if (test-path $fullFilePath) {
    $qualysStatus = get-content -Path $fullFilePath | ConvertFrom-Json
}

#Cleanup
$filePath = $fullFilePath.SubString(0, $fullFilePath.LastIndexOf("\"))
Remove-Item -Recurse $filePath -Force


#Compliance Work Here

$qualysStatus.Certificates.Installed

$qualysStatus.AgentBackendConnectivity.ConnectionSucceeded

$mods = $qualysStatus.Modules
foreach ($mod in $mods) {
    if ($mod.Name -eq "Vulnerability") {
        $mod.ModuleHealth
    }
}

$mods = $qualysStatus.Modules
foreach ($mod in $mods) {
    if ($mod.Name -eq "Patch Management") {
        $mod.ModuleHealth
    }
}

$mods = $qualysStatus.Modules
foreach ($mod in $mods) {
    if ($mod.Name -eq "SCA") {
        $mod.ModuleHealth
    }
}


#Policy Check
[DateTime]$lastPolicyUpdateTime = $qualysStatus.AgentCommunicationDetails.LastCAPI
$today = get-date
$difference = $today - $lastPolicyUpdateTime
if (($difference.Days) -eq 0) {
    return $true
}else{
    return $false
}


