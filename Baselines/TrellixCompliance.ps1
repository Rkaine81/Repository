[version]$currentVersion = "5.7.9.139"

$trellixAgentInfo = & 'C:\Program Files\McAfee\Agent\cmdagent.exe' /i 

$result = [PSCustomObject]@{
        Component = ($trellixAgentInfo[0].split(":"))[1] -replace (' ')
        AgentMode = ($trellixAgentInfo[1].split(":"))[1] -replace (' ')
        Version = ($trellixAgentInfo[2].split(":"))[1] -replace (' ')
        GUID = ($trellixAgentInfo[3].split(":"))[1] -replace (' ')
        TenantID = ($trellixAgentInfo[4].split(":"))[1] -replace (' ')
        CryptMode = ($trellixAgentInfo[7].split(":"))[1] -replace (' ')
        EPOServerList = ($trellixAgentInfo[9].split(":"))[1] -replace (' ')
        EPOPortList = ($trellixAgentInfo[10].split(":"))[1] -replace (' ')
        EPOServerLastUsed = ($trellixAgentInfo[11].split(":"))[1] -replace (' ')
        LastASCTime = ($trellixAgentInfo[12].split(":"))[1] -replace (' ')
        LastPolicyUpdateTime = (($trellixAgentInfo[13].split(":"))[1]) -replace (' ')
        EPOVersion = ($trellixAgentInfo[14].split(":"))[1] -replace (' ')
        ServerID = ($trellixAgentInfo[15].split(":"))[1] -replace (' ')
}

write-output $result.Version

#Version Check
[version]$appVersion = ($result.Version)

if ($appVersion -lt $currentVersion) {
    return $true
}else{
    return $false
}

#Policy Check
$my_date_24hr_time   = $result.LastPolicyUpdateTime + ".000000+000"
$lastPolicyUpdateTime = [datetime]::ParseExact($my_date_24hr_time,"yyyyMMddHHmmss.000000+000",$null)
$today = get-date

if ($lastPolicyUpdateTime -lt $today) {
    $difference = $today - $lastPolicyUpdateTime
    if (($difference.Days) -eq 0) {
        return $true
    }else{
        return $false
    }
}

#Managed Agent
if ($null -ne $trellixAgentInfo) {
    #Agent Mode Active Check 
    if (($result.AgentMode) -eq 1) {
        return "managed"
    }else{
        return "unmanaged"
    }
}