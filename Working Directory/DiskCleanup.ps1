<# Logging Function
Example: Write-Log "This is a log entry."
#>
Function Write-Log {

    param(
        [Parameter(Mandatory=$true)]
        [string]$VALUE
    )

    $ComputerName = $env:computername
    $LOGPATH = "C:\CHOA"
    #Set Log name
    $LOGFILE = "$ComputerName_DiskCleanup.log"
    $FULLLOGPATH = "$LOGPATH\$LOGFILE"

    write-output "$(get-date): $VALUE" | out-file $FULLLOGPATH -Append -Force -NoClobber

}

$WinTemp = "c:\Windows\Temp\*"  
$winDist = "C:\Windows\SoftwareDistribution"

if ((((get-psdrive C).Free)/1GB) -lt 1000) {

    Write-Log "Free space before cleanup: $((((get-psdrive C).Free)/1GB))"
    Start-Transcript -Path "C:\CHOA\$ComputerName_DiskCleanup.log"
    Remove-Item -Recurse  "$env:TEMP\*" -Force -Verbose   
    Remove-Item -Recurse $WinTemp -Force -Verbose
    Clear-RecycleBin -DriveLetter C -Force
    cleanmgr /sagerun:1 /VeryLowDisk /AUTOCLEAN
    Dism.exe /Online /Cleanup-Image /RestoreHealth
    Dism.exe /online /Cleanup-Image /StartComponentCleanup
    Dism.exe /Online /Cleanup-Image /SPSuperseded
    Start-Process C:\Windows\sytem32\wsreset.exe -Wait
    Get-Service -Name WUAUSERV | Stop-Service
    Remove-Item -Path $winDist -Recurse -Force
    Get-Service -Name WUAUSERV | Start-Service
    Stop-Transcript
    Write-Log "Free space after cleanup: $((((get-psdrive C).Free)/1GB))"
}