$Host.UI.RawUI.WindowTitle = "Windows Configuration Script v1.0 | Adam Eaddy | CHOA Systems Engineering | 2024"
$ErrorActionPreference     = "SilentlyContinue"
$Timestamp1                = Get-Date -format "yyyy-MM-dd hh-mmtt"
$Timestamp2                = Get-Date -format "MMddyyy HHmmss"
$ComputerName              = $env:computername
$OsDrive                   = Get-Volume -FileSystemLabel "Windows"
$OsDriveLetter1            = $OsDrive.DriveLetter
If ($OsDriveLetter1 -ne $NULL)    { $OsDriveLetter = $OsDriveLetter1 + ':' }
Else {$WMILD  = gwmi win32_logicaldisk -Filter "DriveType = '3'"
ForEach ($LD in $WMILD) {$LDName   = $LD.VolumeName
If ($LDName -eq "Windows") {$OsDriveLetter = $LD.DeviceID}}}
$CreateChoaLogDir          = New-Item -ItemType directory -Path "$OsDriveLetter\Windows\Logs\CHOA" -Force
icacls "$OsDriveLetter\Windows\Logs\CHOA" /grant '"Administrators":(OI)(CI)(F)' > $Null # setting folder access rights for Admins
$ScriptPath                = "\\choa-cifs\install\CM_P01\06_InProduction\OperatingSystems\Packages\imageFiles"
$ScriptRoot                = "\\choa-cifs\install\CM_P01\06_InProduction\OperatingSystems\Packages"

#region Functions

#Logging Function
#Example: Write-Log "This is a log entry."
Function Write-Log {

    param(
        [Parameter(Mandatory=$true)]
        [string]$VALUE
    )

    $SDATE = get-date -Format MMddyyyy
    $LOGPATH = "$OsDriveLetter\Windows\Logs\CHOA"
    #Set Log name
    $LOGFILE = "$ComputerName_$SDATE.log"
    $FULLLOGPATH = "$LOGPATH\$LOGFILE"

    write-output "$(get-date): $VALUE" | out-file $FULLLOGPATH -Append -Force -NoClobber

}

<# File Copy Function 
Copy-File -Source <source> -destination <dest>
Exit Codes:
0 = file copy successful
1 = file copy failed
2 = Source path not found
#>
function Copy-File {

param( [string]$Source, [string]$Destination )

    If (Test-Path $Source) {
        Copy-Item -Path $Source -Destination $Destination  -PassThru -Force                                                                    
        If (!(Test-Path $Destination)) { 
            return 1  
        }Else{ 
            return 0
        }                                                                                                                        
    }Else{                                                                    
        return 2                                                                                                                    
    }
}




#endregion

### Computer Based Settings ###
Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
Write-Log "Beginning the configuration of Computer related settings."
Write-Host "Beginning the configuration of Computer related settings."


### Copying User Account images ###
Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
Write-Log "Beginning the file copy process."
Write-Host "Beginning the file copy process."

 #Source   Destination
$UserAcctImagePaths=@(
@("$ScriptPath\UserAccountPictures\user.bmp", "$OsDriveLetter\ProgramData\Microsoft\User Account Pictures"),           # user.bmp
@("$ScriptPath\UserAccountPictures\user.png", "$OsDriveLetter\ProgramData\Microsoft\User Account Pictures"),           # user.png
@("$ScriptPath\UserAccountPictures\user-32.png", "$OsDriveLetter\ProgramData\Microsoft\User Account Pictures"),        # user-32.png
@("$ScriptPath\UserAccountPictures\user-40.png", "$OsDriveLetter\ProgramData\Microsoft\User Account Pictures"),        # user-40.png
@("$ScriptPath\UserAccountPictures\user-48.png", "$OsDriveLetter\ProgramData\Microsoft\User Account Pictures"),        # user-48.png
@("$ScriptPath\UserAccountPictures\user-192.png", "$OsDriveLetter\ProgramData\Microsoft\User Account Pictures"))       # user-192.png

    Try {
        foreach ($UserAcctImagePath in $UserAcctImagePaths) {
        
            $USRACTIMGP00 = $UserAcctImagePath[0]
            $USRACTIMGP01 = $UserAcctImagePath[1]

            Write-Log "Copying $USRACTIMGP00 to $USRACTIMGP01"
            Write-Host "Copying $USRACTIMGP00 to $USRACTIMGP01"
            Copy-File -Source $USRACTIMGP00 -Destination $USRACTIMGP01
            $USRACTIMGP00 = $null
            $USRACTIMGP01 = $null
            Write-Log "Successfully copied $USRACTIMGP00 to $USRACTIMGP01"
            Write-Host "Successfully copied $USRACTIMGP00 to $USRACTIMGP01"
 
        }
    }

    Catch{
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Error: Failed to copy the file ($USRACTIMGP00) to the location ($USRACTIMGP01) : Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
            Write-Host "Error: Failed to copy the file ($USRACTIMGP00) to the location ($USRACTIMGP01) : Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
    }