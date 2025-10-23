if (!(Test-path "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WMI\WMI-Module.psm1")) {
    $modeulFile = "\\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\CHOAWMIClass\WMI-Module.psm1"
    $localPath = "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WMI\WMI-Module.psm1"

    if (!(Test-Path $modeulFile)) {
        return $false
    }

    if (!(Test-Path $localPath)) {
        if (!(Test-Path "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WMI")) {
            New-Item -ItemType Directory -Path "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WMI" -Force
            Copy-Item $modeulFile $localPath -Force
        }
    }
}

if (Test-path "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WMI\WMI-Module.psm1") {
    Import-Module C:\Windows\System32\WindowsPowerShell\v1.0\Modules\WMI\WMI-Module.psm1
}else{
    return $false
}

New-WMIClass -ClassName "CHOA"

# Remove-WMIClass -ClassName "CHOA" -Force

#Location
if (test-path "C:\Apps\CurrentLocation\Current.txt") {
    $LOCATION = ((get-content -Path "C:\Apps\CurrentLocation\Current.txt").TrimStart(" ")).TrimEnd(" ")
    New-WMIProperty -ClassName "CHOA" -PropertyName "Location0" -PropertyValue $LOCATION
}else{
    New-WMIProperty -ClassName "CHOA" -PropertyName "Location0" -PropertyValue " "
}

#LastLocation
if (Test-Path "C:\Apps\CurrentLocation\last.txt") {
    $LASTLOCATION = ((get-content -Path "C:\Apps\CurrentLocation\last.txt").TrimStart(" ")).TrimEnd(" ")
    New-WMIProperty -ClassName "CHOA" -PropertyName "Location1" -PropertyValue $LASTLOCATION
}else{
    New-WMIProperty -ClassName "CHOA" -PropertyName "Location1" -PropertyValue $null
}

if (Test-Path "C:\Apps\$env:COMPUTERNAME\ComputerInfo.txt") {
    $COMPUTERDATA = get-content -Path "C:\Apps\$env:COMPUTERNAME\ComputerInfo.txt"
    $result = [PSCustomObject]@{
        ImagedDate = (($COMPUTERDATA -match "Imaged Date:").split(":"))[1] -replace (' ')
        LastReboot = (((($COMPUTERDATA -match "Last Reboot:").split(":"))[1]).TrimStart(' ')).TrimEnd(' ')
        PCStatus = (($COMPUTERDATA -match "PC Status:").split(":"))[1] -replace (' ')
    }

    #ImagedDate
    New-WMIProperty -ClassName "CHOA" -PropertyName "ImagedDate" -PropertyValue $result.ImagedDate

    #LastReboot
    New-WMIProperty -ClassName "CHOA" -PropertyName "DaysSinceLastReboot" -PropertyValue $result.LastReboot

    #PCStatus
    New-WMIProperty -ClassName "CHOA" -PropertyName "PCStatus" -PropertyValue $result.PCStatus
}else{
    #ImagedDate
    New-WMIProperty -ClassName "CHOA" -PropertyName "ImagedDate" -PropertyValue " "

    #LastReboot
    New-WMIProperty -ClassName "CHOA" -PropertyName "DaysSinceLastReboot" -PropertyValue " "

    #PCStatus
    New-WMIProperty -ClassName "CHOA" -PropertyName "PCStatus" -PropertyValue " "
}



#Baselines need to write to these
    #ServicesRunning
    New-WMIProperty -ClassName "CHOA" -PropertyName "ServicesRunning" -PropertyValue " "
    #LastServiceCheckDate
    New-WMIProperty -ClassName "CHOA" -PropertyName "ServicesRunningCheckDate" -PropertyValue " "
    #GroupPolicyHealthy
    New-WMIProperty -ClassName "CHOA" -PropertyName "GroupPolicyHealthy" -PropertyValue " "
    #LastGroupPolicyHelathCheckDate
    New-WMIProperty -ClassName "CHOA" -PropertyName "GroupPolicyHelathCheckDate" -PropertyValue " "
    #CleantHealthScriptPresent
    New-WMIProperty -ClassName "CHOA" -PropertyName "CleantHealthScriptPresent" -PropertyValue " "
    #LastClientHeathCeckDate
    New-WMIProperty -ClassName "CHOA" -PropertyName "ClientHeathCeckDate" -PropertyValue " "


# get-wmiclass -ClassName "CHOA"
# ((get-wmiclass -ClassName "CHOA").Properties).Value