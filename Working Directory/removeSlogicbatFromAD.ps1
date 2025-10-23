$OU = "OU=O365 Pilot,OU=Users,OU=CHOA Accounts,DC=CHOA,DC=ORG"


<# Logging Function
Example: Write-Log "This is a log entry."
#>
Function Write-Log {

    param(
        [Parameter(Mandatory=$true)]
        [string]$VALUE
    )

    $SDATE = get-date -Format MMddyyyy
    $ComputerName = $env:computername
    $LOGPATH = $env:TEMP
    #Set Log name
    $LOGFILE = "sLogicCleanup.log"
    $FULLLOGPATH = "$LOGPATH\$LOGFILE"

    write-output "$(get-date): $VALUE" | out-file $FULLLOGPATH -Append -Force -NoClobber

}

write-host "The log file can be found in: $logfile." -ForegroundColor Green

write-host "Getting members of OU: $OU."
Write-Log "Getting members of OU: $OU."

$users = get-aduser -filter * -searchbase $OU -properties scriptpath

foreach ($user in $users) {
    
    if ($user.scriptpath -eq "sLogic.bat") {
        Write-Host "Setting script path variable for: $($User.name)"
        Write-Log "Setting script path variable for: $($User.name)"
        Try {
            Set-ADUser -Identity $user -ScriptPath " "
            Write-Host "Successfully cleared scriptPath value for: $($User.name)"
            Write-Log "Successfully cleared scriptPath value for: $($User.name)"
        }
        Catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Failed clearing the scriptPath value.: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        }

    }
}


write-host "Finished.  See log for details." -ForegroundColor Green
write-host "The log file can be found in: $logfile." -ForegroundColor Green