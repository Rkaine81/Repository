#Set Windows Service states. Start/Stop services and Set Start type.
function check-service {

    param(
        [Parameter(Mandatory=$true)]
        [string]$SERVICE,
        [Parameter(Mandatory=$true)]
        [ValidateSet('Disabled','Manual','Automatic', 'Automatic (Delayed Start)')]
        [string]$STARTTYPE,
        [Parameter(Mandatory=$true)]
        [ValidateSet('Start','Stop')]
        [string]$ACTION
    
    )

    Try {

        if ($ACTION -eq "Stop") {$STATUS = "Stopped"} 
        if ($ACTION -eq "Start") {$STATUS = "Running"} 

        
        if ((get-service $SERVICE).StartType -ne $STARTTYPE) {Set-Service -Name $SERVICE -StartupType $STARTTYPE}
        if (!(get-service $SERVICE).Status -eq $STATUS) {$ACTION-service -Name $SERVICE}

    }

    Catch {
        AppendLog "$((Get-PSCallStack)[1].Command) Set Registry Value failed: $LASTEXITCODE; Error Details: $($_.ErrorDetails); Error Stack Trace: $($_.ScriptStackTrace); Target Object: $($_.TargetObject); Invocation Info: $($_.InvocationInfo)"
    }
}




        if ($STARTTYPE -eq "Disabled") {
            if ((get-service $SERVICE).Status -eq "Running") {Stop-Service -Name $SERVICE}
        }

        if ($STARTTYPE -eq 'Automatic' -or $STARTTYPE -eq 'Automatic (Delayed Start)') {
            if ((get-service $SERVICE).Status -eq "Stopped") {Start-Service -Name $SERVICE}
        }

        if ((get-service $SERVICE).StartType -ne $STARTTYPE) {Set-Service -Name $SERVICE -StartupType $STARTTYPE}