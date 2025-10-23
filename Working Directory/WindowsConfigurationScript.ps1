$Host.UI.RawUI.WindowTitle = "Windows Configuration Script v1.0 | Adam Eaddy | CHOA Systems Engineering | 2024"
$ErrorActionPreference     = "SilentlyContinue"
$Timestamp1                = Get-Date -format "yyyy-MM-dd hh-mmtt"
$Timestamp2                = Get-Date -format "MMddyyy HHmmss"
$ComputerName              = $env:computername
$ScriptPath                = "\\choa-cifs\install\CM_P01\06_InProduction\OperatingSystems\Packages\imageFiles"
$OsDrive                   = Get-Volume -FileSystemLabel "Windows"
$OsDriveLetter1            = $OsDrive.DriveLetter
If ($OsDriveLetter1 -ne $NULL)    { $OsDriveLetter = $OsDriveLetter1 + ':' }
Else {$WMILD  = gwmi win32_logicaldisk -Filter "DriveType = '3'"
ForEach ($LD in $WMILD) {$LDName   = $LD.VolumeName
If ($LDName -eq "Windows") {$OsDriveLetter = $LD.DeviceID}}}
$ChoaLogDir                = New-Item -ItemType directory -Path "$OsDriveLetter\Windows\Logs\CHOA" -Force
icacls "$OsDriveLetter\Windows\Logs\CHOA" /grant '"Administrators":(OI)(CI)(F)' > $Null # setting folder access rights for Admins

#region Functions

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
    $LOGPATH = "C:\Windows\Logs\CHOA"
    #Set Log name
    $LOGFILE = "$ComputerName_$SDATE.log"
    $FULLLOGPATH = "$LOGPATH\$LOGFILE"

    write-output "$(get-date): $VALUE" | out-file $FULLLOGPATH -Append -Force -NoClobber

}

<# File Copy Function 
Example: Copy-File -Source <source> -Destination <dest>
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

<# Folder Copy Function
Example: CopyFolder -Source <source> -Destination <dest>
Exit Codes:
0 = file copy successful
1 = Source path not found
#>
function CopyFolder {

param( [string]$Source, [string]$Destination )

    $SourceDir = "$Source\*"
    $DestinationDir = "$Destination\"

    If (Test-Path $Source) {
        If (!(Test-Path $Destination)) {
            New-Item -ItemType directory -Path $Destination -Force
        }
        $result = Copy-Item $SourceDir -Destination $DestinationDir -PassThru -Recurse -Force                                                                    
        return 0                                                                                                                                                                                                                                                      
    }Else{                                                                   
        return 1                                                                                                                
    }
}

<# Remove Built-in Windows Apps Function
Example: Set-WindowsApps -AppName "XBox"
#>
Function Set-WindowsApps {

    param(
        [Parameter(Mandatory=$true)]        
        [string]$AppName
    )
    

        Get-AppxPackage -Name $AppName| Remove-AppxPackage
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $AppName | Remove-AppxProvisionedPackage -Online

}

<# Configures PSRemoting settings function
Examples:
Set-PSRemoting -SetState Enable
Set-PSRemoting -SetState Disable
#>
Function Set-PSRemoting {
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('Enable', 'Disable')]
        [string]$SetState
    )
    If ($SetState -eq 'Enable') {
        Enable-PSRemoting -Force -SkipNetworkProfileCheck
        Check-Service -SERVICE "WinRM" -STARTTYPE Automatic -ACTION Start
    } Elseif ($SetState -eq 'Disable') {
        Disable-PSRemoting -Force
        Check-Service -Service "WinRM" -STARTTYPE Disabled -ACTION Stop
    }

}

<# Enable/Disable Scheduled Task function
Examples:
Exit Codes:
0 = Successfully changed state
1 = Failed to change state
2 = State already set as expected
Set-SchedTasks -TaskName GoogleUpdateTask -RunState Disabled
Set-SchedTasks -TaskName GoogleUpdateTask -RunState Enabled
#>
Function Set-SchedTasks {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$TaskName,
        [Parameter(Mandatory=$true)]
        [ValidateSet('Enabled', 'Disabled')]
        [string]$RunState

    )

    if ($runstate -eq "disabled") {
        foreach ($SCHEDTSK in $SCHEDTASKS1) {
            if (($SCHEDTSK.State) -eq $RunState) {
                return 2
            }else{
            $command = Disable-ScheduledTask -InputObject $SCHEDTSK
                if (($command.State) -eq "Disabled") {
                    return 0
                }else{
                    return 1
                }
            }
        }

    }
    
    if ($runstate -eq "enabled") {
        foreach ($SCHEDTSK in $SCHEDTASKS1) {
            if (($SCHEDTSK.State) -eq $RunState) {
                return 2
            }else{
            $command = Disable-ScheduledTask -InputObject $SCHEDTSK
                if (($command.State) -eq "enabled") {
                    return 0
                }else{
                    return 1
                }
            }
        }

    }

}

# function Set Wallpaper with Parameters - Rev. 02/18/2023
function SetWallpaper {

param( [string]$imgPath )

$code = @' 

using System.Runtime.InteropServices; 

namespace Win32{ 
    
     public class Wallpaper{ 
        [DllImport("user32.dll", CharSet=CharSet.Auto)] 
         static extern int SystemParametersInfo (int uAction , int uParam , string lpvParam , int fuWinIni) ; 
         
         public static void SetWallpaper(string thePath){ 
            SystemParametersInfo(20,0,thePath,3); 
         }
    }
 } 
'@

    add-type $code 

    #Apply the Change on the system 
    [Win32.Wallpaper]::SetWallpaper($imgPath)

    Write-Host ""
    Write-Host "Setting desktop wallpaper to $imgPath"

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



$UserAcctImagePaths=@(
               #Source                                                     Destination
@("$ScriptPath\UserAccountPictures\user.bmp"     , "$OsDriveLetter\ProgramData\Microsoft\User Account Pictures"),           # user.bmp
@("$ScriptPath\UserAccountPictures\user.png"     , "$OsDriveLetter\ProgramData\Microsoft\User Account Pictures"),           # user.png
@("$ScriptPath\UserAccountPictures\user-32.png"  , "$OsDriveLetter\ProgramData\Microsoft\User Account Pictures"),           # user-32.png
@("$ScriptPath\UserAccountPictures\user-40.png"  , "$OsDriveLetter\ProgramData\Microsoft\User Account Pictures"),           # user-40.png
@("$ScriptPath\UserAccountPictures\user-48.png"  , "$OsDriveLetter\ProgramData\Microsoft\User Account Pictures"),           # user-48.png
@("$ScriptPath\UserAccountPictures\user-192.png" , "$OsDriveLetter\ProgramData\Microsoft\User Account Pictures"))           # user-192.png

    Try {
        foreach ($UserAcctImagePath in $UserAcctImagePaths) {
        
            $USRACTIMGP00 = $UserAcctImagePath[0]
            $USRACTIMGP01 = $UserAcctImagePath[1]

            Write-Log "Copying $USRACTIMGP00 to $USRACTIMGP01"
            Write-Host "Copying $USRACTIMGP00 to $USRACTIMGP01"
            Copy-File -Source $USRACTIMGP00 -Destination $USRACTIMGP01
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



$BuildFiles=@(
      #Source                                               Destination
@("$ScriptPath\cap.ico"                          , "$OsDriveLetter\Windows"),                       # Icon file
@("$ScriptPath\cap-new.ico"                      , "$OsDriveLetter\Windows"),                       # Icon File
@("$ScriptPath\Children's Application Portal.url", "$OsDriveLetter\Users\Public\Desktop"),          # CHOA Portal shortcut
@("$ScriptPath\cmtrace.exe"                      , "$OsDriveLetter\Windows\System32"),              # CMtrace log viewer
@("$ScriptPath\My System Information.lnk"        , "$OsDriveLetter\Users\Public\Desktop"),          # My System Info desktop shortcut
@("$ScriptPath\systeminfo2.exe"                  , "$OsDriveLetter\Windows\System32"),              # Custom system info utility
@("$ScriptPath\wallpaper10std.bmp"               , "$OsDriveLetter\Windows\Web\Wallpaper\CHOA"      # CHOA Wallpaper
@("$ScriptPath\StartEncryption.cmd"              , "$OsDriveLetter\Users\Public"),                  # 
@("$ScriptPath\StartEncryption.ps1"              , "$OsDriveLetter\Users\Public"),                  #
@("$ScriptPath\Start Encryption Run as Admin.lnk", "$OsDriveLetter\Users\Administrator\Desktop"))   #

    Try {
        foreach ($BuildFile in $BuildFiles) {
        
            $BFILE00 = $BuildFile[0]
            $BFILE01 = $BuildFile[1]

            Write-Log "Copying $BFILE00 to $BFILE01"
            Write-Host "Copying $BFILE00 to $BFILE01"
            Copy-File -Source $BFILE00 -Destination $BFILE01
            Write-Log "Successfully copied $BFILE00 to $BFILE01"
            Write-Host "Successfully copied $BFILE00 to $BFILE01"
 
        }
    }

    Catch{
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Error: Failed to copy the file ($USRACTIMGP00) to the location ($USRACTIMGP01) : Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
            Write-Host "Error: Failed to copy the file ($USRACTIMGP00) to the location ($USRACTIMGP01) : Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
    }

    ### Remove Windows Apps ###
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Beginning the Removal of built-in Windows Apps."
    Write-Host "Beginning the Removal of built-in Windows Apps."

    $WindowsApps = @(
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxGamingOverlay"
        "Microsoft.XboxIdentityProvider"
        "Microsoft.XboxGameCallableUI"
    )

    Try {
        foreach ($WindowsApp in $WindowsApps) {

            Set-WindowsApps -AppName $WindowsApp

        }
    }

    Catch{ 
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        $FullMessage = $Error[0].Exception.GetType().FullName
        Write-Log "Removing the Windows Apps failed: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        Write-Host "Removing the Windows Apps failed: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
    }


### Enable PSRemoting ###
Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
Write-Log "Enabling PSRemoting settings"
Write-Host "Enabling PSRemoting settings"

#Remote State
$RemStat="Enable"   #Enable PSremoting settings
    Try {
        Set-PSRemoting -SetState $RemStat     
    }
    Catch{ 
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        $FullMessage = $Error[0].Exception.GetType().FullName
        Write-Log "Failed to enable PSRemoting: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
    }



### Configure Application Scheduled Tasks ###
Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
Write-Log "Beginning the configuration of Application Scheduled Tasks."


$WindowsTasks=@(
#  Task Name     StartupType
@("*Adobe*"    , "Disabled"),      #Adobe Acrobat Update Task
@("*Google*"   , "Disabled"),      #GoogleUpdateTaskMachineCore
@("*OneDrive*" , "Disabled"))       #GoogleUpdateTaskMachineUA

    Try {
        foreach ($WindowsTask in $WindowsTasks) {
    
            $TASKNAMETOCHECK = $WindowsTask[0]
            $TASKSTARTUPTYPE = $WindowsTask[1]
            Set-SchedTasks $TASKNAMETOCHECK $TASKSTARTUPTYPE
        }
    }

    Catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        $FullMessage = $Error[0].Exception.GetType().FullName
        Write-Log "Modifying the tasks $TASKNAMETOCHECK failed: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
    }



### Setting Wallpaper ###
Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
Write-Log "Beginning the wallpaper configuration."
Write-Host "Beginning the wallpaper configuration."


$imgPath="C:\Windows\Web\Wallpaper\CHOA\Wallpaper10std.bmp"
Try {
    SetWallpaper -imgPath $imgPath
}
Catch {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    $FullMessage = $Error[0].Exception.GetType().FullName
    Write-Log "Failed setting the wallpaper to ($imgPath): Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
}