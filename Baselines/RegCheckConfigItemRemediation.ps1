#CfgItem Registry Value Exists
$regKey = "hkcu:\SOFTWARE\Microsoft\Office\16.0\Common\Identity"
$regValue = "DisableOneAuth"
$regValueProperty = "1"
$regType = "DWord"

 Function WriteRegKey{
 #Create registry path if it doesn't exist. Then modify entry value. 
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

WriteRegKey $regKey $regValue $regType $regValueProperty
