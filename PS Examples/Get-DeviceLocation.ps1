
Function Get-DeviceLocation {
    $locationData = Import-Csv -Path "\\choa-cifs\install\CM_P01\06_InProduction\OperatingSystems\Packages\Image Files\LocationData\CHOAsubnets.csv" -Header Subnet, Location, Shortname
    #$ipInfo = Get-NetIPAddress | where {$_.AddressFamily -eq "IPv4" -and $_.IPAddress -ne "127.0.0.1" -and $_.IPAddress -notlike "169*" -and $_.InterfaceAlias -ne "Wi-Fi"}
    $ipInfo = (Test-NetConnection choa.org).sourceAddress.IPaddress
    $ipLocations = New-Object System.Collections.ArrayList

    $loc = "Default"
    $ipAddress = $ipInfo
    $SplitItem = $ipAddress -split '\.'
    $SplitItem[3] = ""
    $deviceSubnet = $SplitItem -Join '.'
    $deviceSubnet = $deviceSubnet.TrimEnd(".")
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
        #$ipAddress = $obj.IPAddress
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

    $actualSite = "Not on physical CHOA network"
    foreach ($ipLocation in $ipLocations) {
        if (!($ipLocation -eq "VPN" -or $ipLocation -like "*HOME*" -or $ipLocation -like "*Remote*")) {
            $actualSite = $ipLocation
        }
    }

    $actualSite
}

Get-DeviceLocation