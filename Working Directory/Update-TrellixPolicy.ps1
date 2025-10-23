$cmdagentinfolog = "C:\Users\Public\cmdagentinfo.log"

If ( Test-Path $cmdagentinfolog ) { 

$Result = Select-String -Path $cmdagentinfolog -Pattern "AgentMode:" -CaseSensitive -SimpleMatch 

[string]$ResultRead = $Result.Line

If ($ResultRead -match 'AgentMode: 1') {
                                          Write-Host "Trellix Agent is in Managed Mode!"
                                       }

Else {  
        
        Write-Host "Trellix Agent still seems to be in Unmanaged Mode. Running Trellix Agent commands..."
        Write-Host ""

        Write-Host "Changing Trellix Agent to Managed mode to get policies and start encryption"
        $Arg01 = '-provision -managed -dir C:\ProgramData\McAfee\Agent'
        Start-Process -FilePath "C:\Program Files\McAfee\Agent\maconfig.exe" -ArgumentList $Arg01 `
                                                                             -NoNewWindow `
                                                                             -PassThru `
                                                                             -RedirectStandardError  C:\Users\Public\maconfig-error2.log `
                                                                             -RedirectStandardOutput C:\Users\Public\maconfig2.log `
                                                                             -Wait
        Start-Sleep -s 20
        Write-Host ""
        Write-Host "Running Trellix commandline Agent to checks for new policies"
        $Arg02 = '/c /l C:\Users\Public'
        Start-Process -FilePath "C:\Program Files\McAfee\Agent\cmdagent.exe" -ArgumentList $Arg02 `
                                                                             -NoNewWindow `
                                                                             -PassThru `
                                                                             -Wait
        Start-Sleep -s 10
        Write-Host ""
        Write-Host "Running Trellix commandline Agent to enforce policies locally"
        $Arg03 = '/e /l C:\Users\Public'
        Start-Process -FilePath "C:\Program Files\McAfee\Agent\cmdagent.exe" -ArgumentList $Arg03 `
                                                                             -NoNewWindow `
                                                                             -PassThru `
                                                                             -Wait
        Start-Sleep -s 10
        Write-Host ""
        Write-Host "Running Trellix commandline Agent to collect and send properties"
        $Arg04 = '/p /l C:\Users\Public'
        Start-Process -FilePath "C:\Program Files\McAfee\Agent\cmdagent.exe" -ArgumentList $Arg04 `
                                                                             -NoNewWindow `
                                                                             -PassThru `
                                                                             -Wait
    } # Else end

}