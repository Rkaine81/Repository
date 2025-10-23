$ErrorActionPreference = "SilentlyContinue"

$absoluteResult = [PSCustomObject]@{
    absoluteESN = ((& 'C:\Apps\AbtPS\AbtPS.exe' -ESN) | where {$_ -like "Device*"}).split(":")[1] -replace (' ')
    absoluteAgentVersion = ((& 'C:\Apps\AbtPS\AbtPS.exe' -version) | where {$_ -like "Agent*"}).split(" ")[2] -replace (' ')
    absoluteLastCallResult = ((& 'C:\Apps\AbtPS\AbtPS.exe' -lastcallresult) | where {$_ -like "Last*"}).split(" ")[2] -replace (' ')
    absoluteStatus = ((& 'C:\Apps\AbtPS\AbtPS.exe' -status) | where {$_ -like "Persistence*"}).split(" ")[1] -replace (' ')
    absoluteLastCall = (((& 'C:\Apps\AbtPS\AbtPS.exe' -calltimes) | where {$_ -like "Last*"}).split(":")[1] + ":" + ((& 'C:\Apps\AbtPS\AbtPS.exe' -calltimes) | where {$_ -like "Next*"}).split(":")[2]).trimStart(" ")
    absoluteNextCall = (((& 'C:\Apps\AbtPS\AbtPS.exe' -calltimes) | where {$_ -like "Next*"}).split(":")[1] + ":" + ((& 'C:\Apps\AbtPS\AbtPS.exe' -calltimes) | where {$_ -like "Next*"}).split(":")[2]).trimStart(" ")
}


#Registered
if (!($null -eq ($absoluteResult.absoluteESN))) {
    return $true
}else{
    return $false
}


#Activated
if (($absoluteResult.absoluteStatus) -eq "Activated") {
    return $true
}else{
    return $false
}



#Communicating
if (($absoluteResult.absoluteLastCallResult) -eq "succeeded") {
    return $true
}else{
    return $false
}


#Version
if (($absoluteResult.absoluteAgentVersion) -eq "8.994.0.9") {
    return $true
}else{
    return $false
}




