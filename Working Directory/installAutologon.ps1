$SDATE = get-date -Format MMddyyyy
$LOGPATH = "C:\Windows\Logs"
#Set Log name
$LOGFILE = "AutoLogon_$SDATE.log"
$FULLLOGPATH = "$LOGPATH\$LOGFILE"
$compName = $env:COMPUTERNAME
$alUser = "user"+$compName
$alVar1=[string][char[]][int[]]("38.88.120.70.81.119.51.51.118.55.99.103".Split(".")) -replace " "


Function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VALUE
    )
    write-output "$(get-date): $VALUE" | out-file $FULLLOGPATH -Append -Force -NoClobber
}



#Beginning Configuration
Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
Write-Log "Beginning Configuration of $env:COMPUTERNAME."
Write-Log "Beginning installation of Autologon.exe"
$ReturnFromEXE = Start-Process "C:\users\public\Autologon.exe" -ArgumentList "$alUser","CHOA",$alVar1,"/accepteula" -NoNewWindow -Wait -Passthru
Write-Log "App finished with exit code  $($ReturnFromEXE.ExitCode)"
