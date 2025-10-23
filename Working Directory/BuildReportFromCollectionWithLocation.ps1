$CSVPath = "C:\Users\179944\OneDrive - CHOA\scripts\working directory\CHOAsubnets.csv"

$CSV = Import-Csv -Path $CSVPath -Header subnet, location, code

$SiteCode = "P01" 
$ProviderMachineName = "DCVWP-SCCMAP01.choa.org" 
$initParams = @{}
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams | Out-Null
}

Set-Location "$($SiteCode):\" @initParams

$collection = Get-CMDeviceCollection -Id P010049F
$devices = Get-CMCollectionMember -InputObject $collection

foreach ($deviceobj in $devices) {

    $Device = Get-CMDevice -ResourceId ($deviceobj.ResourceID) -Resource -Fast
    $subnets = $Device.IPSubnets
    $subnets = $subnets | % { ([ipaddress]$_).GetAddressBytes()[0..2] -join '.' }

    foreach ($subnet in $subnets) {
    
        if (($CSV.subnet) -contains $subnet) {
            foreach ($obj in $CSV) {
                $csv_subnet = ($obj.subnet)
                if ($csv_subnet -eq $subnet) {
                    Write-Output " $($Device.Name);$($obj.location);$subnet;$($deviceobj.PrimaryUser);$($deviceobj.LastPolicyRequest);$($deviceobj.DeviceOS);$($deviceobj.DeviceOSBuild)" | out-file "C:\choa\SecureSSOComputers.csv" -Append -Force
                }
            }
        }else{
            write-output "old $Subnet not found" | out-file "C:\choa\SecureSSOComputers.log" -Append -Force
            write-host "old $Subnet not found" -ForegroundColor Red
            $subnet = $subnet | % { ([ipaddress]$_).GetAddressBytes()[0..1] -join '.' }
            if (($CSV.subnet) -contains $subnet) {
                foreach ($obj in $CSV) {
                    $csv_subnet = ($obj.subnet)
                    if ($csv_subnet -eq $subnet) {
                        Write-Output " $($Device.Name);$($obj.location);$subnet;$($deviceobj.PrimaryUser);$($deviceobj.LastPolicyRequest);$($deviceobj.DeviceOS);$($deviceobj.DeviceOSBuild)" | out-file "C:\choa\SecureSSOComputers.csv" -Append -Force
                    }
                }
            }else{
                write-output "new $subnet not found" | out-file "C:\choa\SecureSSOComputers.log" -Append -Force
                write-host "new $subnet not found" -ForegroundColor Red
            }
        }
    }
}
