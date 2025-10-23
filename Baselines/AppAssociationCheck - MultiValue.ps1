#Check

$Counter = 0

#File
$appAssoc = Test-Path C:\windows\AppAssociations.xml
if(!($appAssoc))
    { $Counter+=1 }

#Registry
$path = "C:\windows\AppAssociations.xml"
$appAssocReg = Get-ItemProperty HKLM:\Software\Policies\Microsoft\Windows\System -Name DefaultAssociationsConfiguration
if($appAssocReg.DefaultAssociationsConfiguration -ne $path)
    { $Counter+=1 }

if($Counter -eq 0) { 
    Write-Output $true 
}else{
    Write-Output $false 
}


#Remediation
#Create registry path if it doesn't exist. Then modify entry value. 
 Function WriteRegKey{
 
    Param(
        [Parameter(Mandatory=$true)]
        [string]$registryPath,
        [Parameter(Mandatory=$true)]
        [string]$regName,
        [Parameter(Mandatory=$true)]
        [string]$regType,
        [Parameter(Mandatory=$true)]
        [string]$regValue
    )
    #Try{
        #Get-ItemProperty $registryPath
        If(!(Test-Path $registryPath)){
            New-Item -Path $registryPath -Force

        }
        New-ItemProperty -Path $registryPath -Name $regName -PropertyType $regType -Value $regValue -Force | Write-Host
    #}
    
    #Catch{AppendLog "$((Get-PSCallStack)[1].Command) Set Registry Value failed: $LASTEXITCODE; Error Details: $($_.ErrorDetails); Error Stack Trace: $($_.ScriptStackTrace); Target Object: $($_.TargetObject); Invocation Info: $($_.InvocationInfo)"}

}


Copy-Item -Path \\choa-cifs1\sccm_sourcefiles\SoftwareDistributionPKGs\IMAGING\CommonFiles\AppAssociations.xml -Destination C:\windows\AppAssociations.xml -Force


WriteRegKey "HKLM:\Software\Policies\Microsoft\Windows\System" "DefaultAssociationsConfiguration" "String" "C:\windows\AppAssociations.xml"

