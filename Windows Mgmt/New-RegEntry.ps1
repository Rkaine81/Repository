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
        New-ItemProperty -Path $registryPath -Name $regName -PropertyType $regType -Value $regValue -Force
    #}
    
    #Catch{AppendLog "$((Get-PSCallStack)[1].Command) Set Registry Value failed: $LASTEXITCODE; Error Details: $($_.ErrorDetails); Error Stack Trace: $($_.ScriptStackTrace); Target Object: $($_.TargetObject); Invocation Info: $($_.InvocationInfo)"}

}

WriteRegKey -registryPath "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\LockDown\AllowEdgeSwipe" -regName "value" -regType "Dword" -regValue "0"
WriteRegKey -registryPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EdgeUI" -regName "AllowEdgeSwipe" -regType "Dword" -regValue "0"