$locationData = Import-Csv -Path "\\choa-cifs\install\CM_P01\06_InProduction\OperatingSystems\Packages\imageFiles\LocationData\CHOAsubnets.csv" -Header Subnet, Location, Shortname

$ipInfo = Get-NetIPAddress | where {$_.AddressFamily -eq "IPv4" -and $_.IPAddress -ne "127.0.0.1" -and $_.IPAddress -notlike "169*" -and $_.InterfaceAlias -ne "Wi-Fi"}
$ipLocations = New-Object System.Collections.ArrayList

foreach ($obj in $ipInfo) {
    $loc = "Default"
    $ipAddress = $obj.IPAddress
    $SplitItem = $ipAddress -split '\.'
    $SplitItem[3] = ""
    $deviceSubnet = $SplitItem -Join '.'
    #$deviceSubnet


    foreach ($locObj in $locationData) {
        $subnet = $locObj.Subnet + "."
        $Location = $locObj.Location
        if ($subnet -eq $deviceSubnet) {
           $ipLocations.Add(@($Location)) > $null
           $loc = $Location
        }
    }

    If ($loc -eq "Default") {
        $ipAddress = $obj.IPAddress
        $SplitItem = $ipAddress -split '\.'
        $SplitItem[2] = ""
        $SplitItem[3] = ""
        $deviceSubnet2 = $SplitItem -Join '.'
        $deviceSubnet2 = $deviceSubnet2.Replace("..",".")
        #$deviceSubnet2
        foreach ($locObj1 in $locationData) {
            $subnet = $locObj1.Subnet + "."
            $Location = $locObj1.Location
            if ($subnet -eq $deviceSubnet2) {
               $ipLocations.Add(@($Location)) > $null
               $loc = $Location
            }
        }
    }
}

$actualSite = "Not on physical CHOA network"
foreach ($ipLocation in $ipLocations) {
    if (!($ipLocation -eq "VPN" -or $ipLocation -like "*HOME*" -or $ipLocation -like "*Remote*")) {
        $actualSite = $ipLocation
    }
}

$actualSite