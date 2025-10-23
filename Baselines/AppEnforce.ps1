#File


$appAssoc = Test-Path C:\windows\AppAssociations.xml

$Counter = 0
    if(!($appAssoc))
        { $Counter+=1 }



#Registry
$appAssocReg = Get-ItemProperty HKLM:\Software\Policies\Microsoft\Windows\System -Name DefaultAssociationsConfiguration
$Counter = 0
Foreach($NetbiosOptionsVlaue in $NetbiosOptionsVlaues )
    {
        if($NetbiosOptionsVlaue.NetbiosOptions -ne 2)
            { $Counter+=1 }
    }


if($Counter -eq 0) { Write-Output $true }
else { Write-Output $false }