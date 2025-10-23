#WMI


$NetBIOS = Get-WmiObject Win32_NetworkAdapterConfiguration -filter "ipenabled = 'true'"
#$NetBIOS.TcpipNetbiosOptions

$Counter = 0
Foreach($NetbiosOptionsValue in $NetBIOS )
    {
        if($NetbiosOptionsValue.TcpipNetbiosOptions -ne 2)
            { $Counter+=1 }
    }
if($Counter -eq 0) { Write-Output $true }
else { Write-Output $false }




#####
$NETBIOS_DISABLED=2
$NETBIOS_DISABLED=0
Get-WmiObject Win32_NetworkAdapterConfiguration -filter "ipenabled = 'true'" | ForEach-Object { $_.SetTcpipNetbios($NETBIOS_DISABLED)}





#Registry
$NetbiosOptionsVlaues = Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces\tcpip* -Name NetbiosOptions
$Counter = 0
Foreach($NetbiosOptionsVlaue in $NetbiosOptionsVlaues )
    {
        if($NetbiosOptionsVlaue.NetbiosOptions -ne 2)
            { $Counter+=1 }
    }
if($Counter -eq 0) { Write-Output $true }
else { Write-Output $false }



####
Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces\tcpip* -Name NetbiosOptions -Value 0