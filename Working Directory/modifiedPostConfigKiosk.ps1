#region Script Info

<#
.DESCRIPTION
    A script to configure Windows in MEMCM Custom Tasks - Post section
.NOTES
    Author         : Edward Korol / CHOA Unified Endpoint Engineering
    Contributer    : Adam Eaddy / CHOA Unified Endpoint Engineering
    Prerequisite   : PowerShell V5.1
    Date           : 2/3/2023
    Modified       : 3/22/2024
.EXAMPLE
    PowerShell Script: CustomTasks-Post.ps1
           Parameters: -ImageType SSO

When this script runs as MDT Task Sequence PowerShell step:

1. to output info to a transcript file (main log file) use Write-Host for messaging
2. to output info to separate log files use Write-Output instead of Write-Host

Edits:
3/22/2024 - AE - Removed all unique build settings except Display PC.
               - Modified file copy section to pull from hardcoded UNC share. Only for testing. 
               - Added function for testing reg keys

#>

#endregion

param(
        [Parameter(Mandatory)]
        [string]$ImageType
     )

#region Script settings

icacls C:\Windows\Logs\CHOA /grant '"Administrators":(OI)(CI)(F)' > $Null # Resetting folder access rights for Admins

$Host.UI.RawUI.WindowTitle = "CustomTasks-Post script | CHOA Systems Engineering | 2024"
$ErrorActionPreference     = "SilentlyContinue"
$Timestamp1                = Get-Date -format "yyyy-MM-dd hh-mmtt"
$Timestamp2                = Get-Date -format "MMddyyy HHmmss"
$ComputerName              = $env:computername
$LogFileFolder             = "C:\Windows\Logs\CHOA"
#$ScriptPathFull            = $MyInvocation.MyCommand.Path       # \\CHOA-MDTDEVBOX\MDT$\Files\CustomTasks-Post.ps1
$ScriptPath                = "\\choa-cifs\install\CM_P01\06_InProduction\OperatingSystems\Packages\Kiosk\Scripts"
$ScriptRoot                = "\\choa-cifs\install\CM_P01\06_InProduction\OperatingSystems\Packages\Kiosk"
$ScriptName                = $MyInvocation.MyCommand.Name       # CustomTasks-Post.ps1

#endregion

# FUNCTIONS - Copy of __Functions-Master Write-Host version for MDT TS runs.ps1
#region FUNCTIONS

#Function to test registry value existance.
#Example: Test-RegistryValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" 
function Test-RegistryValue {

    param (

     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Path,

    [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Value
    )

    try {

        Get-ItemProperty -Path $Path -Name $Value -ErrorAction Stop | Out-Null
        return $true
    }

    catch {

    return $false

    }

}

# function Transcript Section Header with Parameters - Rev. 02/18/2023
function TranscriptSectionHeader {

param( [string]$HeaderName )

Write-Host ""
Write-Host ""
Write-Host "***********************************************************************************************"
Write-Host " $HeaderName - $ScriptName script"
Write-Host "***********************************************************************************************"
Write-Host ""

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

# function Check Trellix Folders - Rev. 02/18/2023
function CheckTrellixDir {

TranscriptSectionHeader -HeaderName "Check If Trellix Folders exist"

$Located = @()
$Missing = @()

$TrellixFolders2check =  "C:\Program Files (x86)\McAfee\Management of Native Encryption",
                        "C:\Program Files\McAfee\Agent",
                        "C:\Program Files\McAfee\Data_Exchange_Layer",
                        "C:\Program Files\McAfee\Endpoint Encryption for Files and Folders",
                        "C:\Program Files\McAfee\DLP",
                        "C:\ProgramData\McAfee\Agent",
                        "C:\ProgramData\McAfee\Common Framework",
                        "C:\ProgramData\McAfee\Data_Exchange_Layer",
                        "C:\ProgramData\McAfee\DLP",
                        "C:\ProgramData\McAfee\Management of Native Encryption"

ForEach ($dir in $TrellixFolders2check) { If (Test-Path -Path $dir) {$Located += $dir}
                                                             Else { $Missing += $dir }}
Write-Host ""
Write-Host "***************** List Trellix Folders *****************"
Write-Host "Located:"
ForEach ($L in $Located) {Write-Host "   $L"}
Write-Host ""
Write-Host "Missing:"
ForEach ($M in $Missing) {Write-Host "   $M"}
Write-Host ""

}

# function Get Bitlocker Volume info - Rev. 02/18/2023
function GetBitlockerVol {

TranscriptSectionHeader -HeaderName "Get Bitlocker Volume info"

$GetBitLockerVolume = Get-BitLockerVolume -MountPoint C: | select -Property *

$GetBitLockerVolumeComputerName         = $GetBitLockerVolume.ComputerName
$GetBitLockerVolumeMountPoint           = $GetBitLockerVolume.MountPoint
$GetBitLockerVolumeEncryptionMethod     = $GetBitLockerVolume.EncryptionMethod
$GetBitLockerVolumeAutoUnlockEnabled    = $GetBitLockerVolume.AutoUnlockEnabled
$GetBitLockerVolumeAutoUnlockKeyStored  = $GetBitLockerVolume.AutoUnlockKeyStored
$GetBitLockerVolumeMetadataVersion      = $GetBitLockerVolume.MetadataVersion
$GetBitLockerVolumeVolumeStatus         = $GetBitLockerVolume.VolumeStatus
$GetBitLockerVolumeProtectionStatus     = $GetBitLockerVolume.ProtectionStatus
$GetBitLockerVolumeLockStatus           = $GetBitLockerVolume.LockStatus
$GetBitLockerVolumeEncryptionPercentage = $GetBitLockerVolume.EncryptionPercentage
$GetBitLockerVolumeWipePercentage       = $GetBitLockerVolume.WipePercentage
$GetBitLockerVolumeVolumeType           = $GetBitLockerVolume.VolumeType
$GetBitLockerVolumeCapacityGB           = $GetBitLockerVolume.CapacityGB
$GetBitLockerVolumeKeyProtector         = $GetBitLockerVolume.KeyProtector

Write-Host ""
Write-Host "************* Get BitLocker Volume Status *************"
Write-Host "Computer Name                : $GetBitLockerVolumeComputerName"
Write-Host "Mount Point                  : $GetBitLockerVolumeMountPoint"
Write-Host "Encryption Method            : $GetBitLockerVolumeEncryptionMethod"
Write-Host "Auto-Unlock Enabled          : $GetBitLockerVolumeAutoUnlockEnabled"
Write-Host "Auto-Unlock Key Stored       : $GetBitLockerVolumeAutoUnlockKeyStored"
Write-Host "Metadata Version             : $GetBitLockerVolumeMetadataVersion"
Write-Host "Volume Status                : $GetBitLockerVolumeVolumeStatus"
Write-Host "Protection Status            : $GetBitLockerVolumeProtectionStatus"
Write-Host "Lock Status                  : $GetBitLockerVolumeLockStatus"
Write-Host "Encryption Percentage        : $GetBitLockerVolumeEncryptionPercentage"
Write-Host "Wipe Percentage              : $GetBitLockerVolumeWipePercentage"
Write-Host "Volume Type                  : $GetBitLockerVolumeVolumeType"
Write-Host "Capacity GB                  : $GetBitLockerVolumeCapacityGB "
Write-Host "Key Protector                : $GetBitLockerVolumeKeyProtector"
Write-Host ""
}

# function Get TPM Status - Rev. 02/18/2023
function GetTPMstatus {

TranscriptSectionHeader -HeaderName "Get TPM Status"

$GetTPM = Get-Tpm

$GetTPMTpmPresent                       = $GetTPM.TpmPresent
$GetTPMTpmReady                         = $GetTPM.TpmReady
$GetTPMTpmEnabled                       = $GetTPM.TpmEnabled
$GetTPMTpmActivated                     = $GetTPM.TpmActivated
$GetTPMTpmOwned                         = $GetTPM.TpmOwned
$GetTPMRestartPending                   = $GetTPM.RestartPending
$GetTPMManufacturerId                   = $GetTPM.ManufacturerId
$GetTPMManufacturerIdTxt                = $GetTPM.ManufacturerIdTxt
$GetTPMManufacturerVersion              = $GetTPM.ManufacturerVersion
$GetTPMManufacturerVersionFull20        = $GetTPM.ManufacturerVersionFull20
$GetTPMManagedAuthLevel                 = $GetTPM.ManagedAuthLevel
$GetTPMOwnerAuth                        = $GetTPM.OwnerAuth
$GetTPMOwnerClearDisabled               = $GetTPM.OwnerClearDisabled
$GetTPMAutoProvisioning                 = $GetTPM.AutoProvisioning
$GetTPMLockedOut                        = $GetTPM.LockedOut
$GetTPMLockoutHealTime                  = $GetTPM.LockoutHealTime
$GetTPMLockoutCount                     = $GetTPM.LockoutCount
$GetTPMLockoutMax                       = $GetTPM.LockoutMax
$GetTPMSelfTest                         = $GetTPM.SelfTest

Write-Host ""
Write-Host "***************** Get TPM Chip Status *****************"
Write-Host "Tpm Present                  : $GetTPMTpmPresent"
Write-Host "Tpm Ready                    : $GetTPMTpmReady"
Write-Host "Tpm Enabled                  : $GetTPMTpmEnabled"
Write-Host "Tpm Activated                : $GetTPMTpmActivated"
Write-Host "Tpm Owned                    : $GetTPMTpmOwned"
Write-Host "Restart Pending              : $GetTPMRestartPending"
Write-Host "Manufacturer Id              : $GetTPMManufacturerId"
Write-Host "Manufacturer Id Txt          : $GetTPMManufacturerIdTxt"
Write-Host "Manufacturer Version         : $GetTPMManufacturerVersion"                        
Write-Host "Manufacturer Version Full 20 : $GetTPMManufacturerVersionFull20"                                                                                            
Write-Host "Managed Auth Level           : $GetTPMManagedAuthLevel"
Write-Host "Owner Auth                   : $GetTPMOwnerAuth" 
Write-Host "Owner Clear Disabled         : $GetTPMOwnerClearDisabled"
Write-Host "Auto-Provisioning            : $GetTPMAutoProvisioning"
Write-Host "Locked Out                   : $GetTPMLockedOut"
Write-Host "Lockout Heal Time            : $GetTPMLockoutHealTime"
Write-Host "Lockout Count                : $GetTPMLockoutCount"
Write-Host "Lockout Max                  : $GetTPMLockoutMax"
Write-Host "Self-Test                    : $GetTPMSelfTest"
Write-Host ""
}

# function Run Trellix Agent Updates - Rev. 02/18/2023
function TrellixAgentUpdate {

TranscriptSectionHeader -HeaderName "Run Trellix Agent Updates"

Write-Host "Changing Trellix Agent to Managed mode to get policies and start encryption"
$Arg01 = '-provision -managed -dir C:\ProgramData\McAfee\Agent'
Start-Process -FilePath "C:\Program Files\McAfee\Agent\maconfig.exe" -ArgumentList $Arg01 `
                                                                     -NoNewWindow `
                                                                     -PassThru `
                                                                     -RedirectStandardError  C:\Users\Public\maconfig-error.log `
                                                                     -RedirectStandardOutput C:\Users\Public\maconfig.log `
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
Start-Sleep -s 10
Write-Host ""
Write-Host "Running Trellix commandline Agent to display agent info"
$Arg05 = '/i /l C:\Users\Public'
Start-Process -FilePath "C:\Program Files\McAfee\Agent\cmdagent.exe" -ArgumentList $Arg05 `
                                                                     -NoNewWindow `
                                                                     -PassThru `
                                                                     -RedirectStandardOutput C:\Users\Public\cmdagentinfo.log `
                                                                     -Wait

}

# function Get Bitlocker Volume Status info - Rev. 02/18/2023
function GetBitlockerVolumeStatus {

TranscriptSectionHeader -HeaderName "Verify Encryption Status"

$GetBitLockerVolumeVolumeStatus = ((Get-BitLockerVolume -MountPoint C: | select -Property VolumeStatus).VolumeStatus)

If     ($GetBitLockerVolumeVolumeStatus -like "FullyDecrypted")       { Write-Host "This computer is not encrypted with Bitlocker!"
                                                                        Write-Host " Running Trellix Agent update..."
                                                                        TrellixAgentUpdate }

ElseIf ($GetBitLockerVolumeVolumeStatus -like "EncryptionInProgress") { Write-Host "Bitlocker encryption in progress! Currently at $EncryptionPercentage %"}

ElseIf ($GetBitLockerVolumeVolumeStatus -like "FullyEncrypted")       { Write-Host "This computer is fully encrypted with Bitlocker!"}

Else                                                                  { Write-Host "Bitlocker status can not be determined!"}

}

# function Encryption Help Message - Rev. 02/03/2023
function EncryptionHelpMessage {

# What to do if computer still not encrypted
Write-Output ""
Write-Output "####################### What to do if computer still not encrypted #######################"
Write-Output ""
Write-Output "Right-click Trellix icon in the notification area and select Trellix Agent Status Monitor..."
Write-Output "Click on buttons 1 through 4 in Trellix Agent Monitor window that opens"
Write-Output "Right-click Trellix icon in the notification area and select Update Security..."
Write-Output "Right-click Trellix icon in the notification area and select About..."
Write-Output "Verify that Trellix Agent status is set to Managed, and DLP and MNE plugins installed"
Write-Output "You may need to restart computer few times for Trellix communication to server to start working"
Write-Output "Open Command Prompt as local Admin and run command below to get BitLocker status manually "
Write-Output "Get-BitLockerVolume -MountPoint C: | select -Property * "
Write-Output "If all attempts to encrypt fail, email Ed Korol with computer name, steps performed, and errors observed "
}

# function VerifyItem with Parameters - Rev. 02/18/2023
function VerifyItem {

param( [string]$What2check )

$PathVerification = (Get-Item $What2check).FullName
$DoesItExist      = (Get-Item $What2check).Exists

If ($DoesItExist -eq "True") { Write-Host "Verified Path: $PathVerification" }
Else { Write-Host "Not found!" }
Write-Host ""

}

# function CreateFolders with Parameters - Rev. 02/18/2023
function CreateFolder {

param( [string]$ItemPath )

$ShortPath = Split-Path -Path $ItemPath -Leaf

If (Test-Path $ItemPath)
    {                                                                    
        Write-Host "$ItemPath folder already exists in this location!"                                                                                           
    }
Else
    {
        $Item = New-Item -ItemType directory -Path $ItemPath                                                 
        Write-Host "Created $Item folder"                                                                                                                               
    }
}

# function DeleteItem with Parameters - Rev. 02/18/2023
function DeleteItem {

param( [string]$FolderPath, [string]$FilePath )

If ($FolderPath) {
                    If (Test-Path $FolderPath) {
                                                 $Item = Remove-Item -Path $FolderPath -Recurse -Force                                                                
                                                 Write-Host "Removed $FolderPath"                                                      
                                                     If (!(Test-Path $FolderPath)) { Write-Host "-- deleted folder successfully!"     } 
                                                     Else                          { Write-Host "-- folder deletion was not successful!" }                                                                       
                                               }
                                          Else { Write-Host "-- $FolderPath folder path was not found!" }
}

If ($FilePath) {
                    If (Test-Path $FilePath) {
                                                 $Item = Remove-Item -Path $FilePath -Force                                                                
                                                 Write-Host "Removed $FilePath"                                                      
                                                     If (!(Test-Path $FilePath)) { Write-Host "-- deleted file successfully!"     } 
                                                     Else                        { Write-Host "-- file deletion was not successful!" }                                                                       
                                               }
                                          Else { Write-Host "-- file was not found at $FilePath" }

}

}

# function MoveItem with Parameters - Rev. 02/18/2023
function MoveItem {

param( [string]$Source, [string]$Destination)

If (Test-Path $Source) {
                            $Result = Move-Item -Path $Source -Destination $Destination -PassThru -Force                                                             
                            Write-Host "Moved $Source to $Destination"
                            $Result 
                            If (!(Test-Path $Destination)) { Write-Host "-- file move failed!"     } 
                            Else                           { Write-Host "-- file move successful!" }                                                                                                                
                       }
Else                   {                                                                   
                            Write-Host "-- $Source was not found!"                                                                                                                      
                       }                                                                        
}

# function MoveFileType with Parameters - Rev. 02/18/2023
function MoveFileType {

param( [string]$Source, [string]$Destination, [string]$FileExtension )

$ItemsList = Get-Item "$Source\*.$FileExtension"

ForEach ($Li in $ItemsList) {
                                $LiFullPath = $Li.FullName
                                $LiName = $Li.Name
                                Move-Item -Path $LiFullPath -Destination $Destination -Force
                                $DestFullPath = "$Destination\$LiName"
                                If (Test-Path $DestFullPath) {Write-Host "Moved $LiFullPath to $DestFullPath"}
                                Else {Write-Host "Did not find $LiName in $Destination"}

                            }
}

# function CopyFile with Parameters - Rev. 02/18/2023
function CopyFile {

param( [string]$Source, [string]$Destination )

If (Test-Path $Source)
    {
    $Item = Copy-Item -Path $Source -Destination $Destination  -PassThru -Force                                                                   
    Write-Host "Copied $Source to $Destination" 
    If (!(Test-Path $Destination)) { Write-Host "-- file copy failed!"     } 
    Else                           { Write-Host "-- file copy successful!" }                                                                                                                        
    }
Else
    {                                                                    
    Write-Host "-- $Source for file copy was not found!"                                                                                                                     
    }
}

# function MoveFileType with Parameters - Rev. 02/18/2023
function CopyFileType {

param( [string]$Source, [string]$Destination, [string]$FileExtension )

$ItemsList = Get-Item "$Source\*.$FileExtension"

ForEach ($Li in $ItemsList) {
                                $LiFullPath = $Li.FullName
                                $LiName = $Li.Name
                                Copy-Item -Path $LiFullPath -Destination $Destination -Force
                                $DestFullPath = "$Destination\$LiName"
                                If (Test-Path $DestFullPath) {Write-Host "Copied $LiFullPath to $DestFullPath"}
                                Else {Write-Host "Did not find $LiName in $Destination"}

                            }
}

# function RenameItem with Parameters - Rev. 02/18/2023
function RenameItem {

param( [string]$ItemFullPath, [string]$NewName, [string]$FileOrFolder )

$OldName  = Split-Path -Path $ItemFullPath -Leaf
$ItemPath = Split-Path -Path $ItemFullPath -Parent
$NewNamePath = "$ItemPath\$NewName"

If ($FileOrFolder -like "file")   { 
                                    If (!(Test-Path $NewNamePath)) {Rename-Item -Path $ItemFullPath -NewName $NewName -Force
                                                                    Write-Host "Renamed $ItemFullPath to $NewNamePath"}
                                    Else {Write-Host "$NewNamePath already exists. File was not renamed"}
                                  }


If ($FileOrFolder -like "folder") { 
                                    If (!(Test-Path $NewNamePath)) {$ItemFullPath2 = $ItemFullPath + '\'
                                                                    Rename-Item -Path $ItemFullPath2 -NewName $NewName -Force
                                                                    Write-Host "Renamed $ItemFullPath to $NewNamePath"}
                                    Else {Write-Host "$NewNamePath already exists. File was not renamed"}
                                  }
}

# function CopyFolder with Parameters - Rev. 02/18/2023
function CopyFolder {

param( [string]$Source, [string]$Destination )

$SourceDir = "$Source\*"
$DestinationDir = "$Destination\"

If (Test-Path $Source)
    {
    If (!(Test-Path $Destination)) {New-Item -ItemType directory -Path $Destination -Force}
    $result = Copy-Item $SourceDir -Destination $DestinationDir -PassThru -Recurse -Force                                                                    
    Write-Host "Copied $SourceDir to $DestinationDir"
    $result                                                                                                                                                                                                                                                       
    }
Else
    {                                                                   
    Write-Host "$Source was not found!"                                                                                                                      
    }
}

# function ListFolderContents with Parameters - external log file - use Write-Output - Rev. 02/18/2023
function ListFolderContents {

param( [string]$FolderPath )

$ListDir = Get-Item "$FolderPath\*"

Write-Host "$FolderPath contents:"
Write-Host ""

ForEach ($i in $ListDir) {
                            $iFullPath = $i.FullName
                            Write-Host "$iFullPath"
                         }
Write-Host ""
}

# function Get-RemoteProgram - Rev. 08/26/2016
function Get-RemoteProgram {
<#
.Synopsis
Generates a list of installed programs on a computer

.DESCRIPTION
This function generates a list by querying the registry and returning the installed programs of a local or remote computer.

.NOTES   
Name       : Get-RemoteProgram
Author     : Jaap Brasser
Version    : 1.3
DateCreated: 2013-08-23
DateUpdated: 2016-08-26
Blog       : http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com

.PARAMETER ComputerName
The computer to which connectivity will be checked

.PARAMETER Property
Additional values to be loaded from the registry. Can contain a string or an array of string that will be attempted to retrieve from the registry for each program entry

.PARAMETER ExcludeSimilar
This will filter out similar programnames, the default value is to filter on the first 3 words in a program name. If a program only consists of less words it is excluded and it will not be filtered. For example if you Visual Studio 2015 installed it will list all the components individually, using -ExcludeSimilar will only display the first entry.

.PARAMETER SimilarWord
This parameter only works when ExcludeSimilar is specified, it changes the default of first 3 words to any desired value.

.EXAMPLE
Get-RemoteProgram

Description:
Will generate a list of installed programs on local machine

.EXAMPLE
Get-RemoteProgram -ComputerName server01,server02

Description:
Will generate a list of installed programs on server01 and server02

.EXAMPLE
Get-RemoteProgram -ComputerName Server01 -Property DisplayVersion,VersionMajor

Description:
Will gather the list of programs from Server01 and attempts to retrieve the displayversion and versionmajor subkeys from the registry for each installed program

.EXAMPLE
'server01','server02' | Get-RemoteProgram -Property Uninstallstring

Description
Will retrieve the installed programs on server01/02 that are passed on to the function through the pipeline and also retrieves the uninstall string for each program

.EXAMPLE
'server01','server02' | Get-RemoteProgram -Property Uninstallstring -ExcludeSimilar -SimilarWord 4

Description
Will retrieve the installed programs on server01/02 that are passed on to the function through the pipeline and also retrieves the uninstall string for each program. Will only display a single entry of a program of which the first four words are identical.
#>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(ValueFromPipeline              =$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0
        )]
        [string[]]
            $ComputerName = $env:COMPUTERNAME,
        [Parameter(Position=0)]
        [string[]]
            $Property,
        [switch]
            $ExcludeSimilar,
        [int]
            $SimilarWord
    )

    begin {
        $RegistryLocation = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\',
                            'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\'
        $HashProperty = @{}
        $SelectProperty = @('ProgramName','ComputerName')
        if ($Property) {
            $SelectProperty += $Property
        }
    }

    process {
        foreach ($Computer in $ComputerName) {
            $RegBase = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,$Computer)
            $RegistryLocation | ForEach-Object {
                $CurrentReg = $_
                if ($RegBase) {
                    $CurrentRegKey = $RegBase.OpenSubKey($CurrentReg)
                    if ($CurrentRegKey) {
                        $CurrentRegKey.GetSubKeyNames() | ForEach-Object {
                            if ($Property) {
                                foreach ($CurrentProperty in $Property) {
                                    $HashProperty.$CurrentProperty = ($RegBase.OpenSubKey("$CurrentReg$_")).GetValue($CurrentProperty)
                                }
                            }
                            $HashProperty.ComputerName = $Computer
                            $HashProperty.ProgramName = ($DisplayName = ($RegBase.OpenSubKey("$CurrentReg$_")).GetValue('DisplayName'))
                            if ($DisplayName) {
                                New-Object -TypeName PSCustomObject -Property $HashProperty |
                                Select-Object -Property $SelectProperty
                            } 
                        }
                    }
                }
            } | ForEach-Object -Begin {
                if ($SimilarWord) {
                    $Regex = [regex]"(^(.+?\s){$SimilarWord}).*$|(.*)"
                } else {
                    $Regex = [regex]"(^(.+?\s){3}).*$|(.*)"
                }
                [System.Collections.ArrayList]$Array = @()
            } -Process {
                if ($ExcludeSimilar) {
                    $null = $Array.Add($_)
                } else {
                    $_
                }
            } -End {
                if ($ExcludeSimilar) {
                    $Array | Select-Object -Property *,@{
                        name       = 'GroupedName'
                        expression = {
                            ($_.ProgramName -split $Regex)[1]
                        }
                    } |
                    Group-Object -Property 'GroupedName' | ForEach-Object {
                        $_.Group[0] | Select-Object -Property * -ExcludeProperty GroupedName
                    }
                }
            }
        }
    }
}

# function ProcessCheck - Rev. 08/16/2023
Function ProcessStatusCheck {

param( [string]$ProcessName )

# Checking if a process is running and stopping it
$ProcessList = @( $ProcessName )
Do {  
    $ProcessesFound = Get-Process | ? {$ProcessList -contains $_.Name} | Select-Object -ExpandProperty Name
    If ($ProcessesFound) {
        $Timestamp = Get-Date -format "yyyy-MM-dd hh-mmtt"
        Write-Output "  $Timestamp    Found $($ProcessesFound) running. Will check again in 30 seconds"
        Stop-Process -Name $ProcessName -Force
        Start-Sleep 30
    }
} Until (!$ProcessesFound)
$Timestamp = Get-Date -format "yyyy-MM-dd hh-mmtt"
Write-Output "  $Timestamp    No $ProcessName process is found running!"

}

Function Test-RegistryValue {
    param(
        [Alias("PSPath")]
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Path
        ,
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$Name
    ) 

    process {
        if (Test-Path $Path) {
            $Key = Get-Item -LiteralPath $Path
            if ($null -ne $Key.GetValue($Name, $null)) {
                $true
            } else {
                $false
            }
        } else {
            $false
        }
    }
}

Function Test-Remove-RegistryValue {
    param (
        [Alias("PSPath")]
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Path
        ,
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$Name
    )

    process {
        if (Test-RegistryValue -Path $Path -Name $Name) {
            Write-Host "Removing registry key $Path\$Name"
            Remove-ItemProperty -Path $Path -Name $Name
        }
    }
}

#endregion

start-transcript -path "C:\Windows\Logs\CHOA\CustomTasksPost-Transcript.txt" -Force

#region Verify if TPM is present on the computer and record status to registry - Rev. 02/18/2023

If ((Get-Tpm).TpmPresent -like "False") { Set-Itemproperty -path "HKLM:\SOFTWARE\Microsoft\Deployment 4" -name "TPM Present During Imaging" -value "No"}
                                   Else { Set-Itemproperty -path "HKLM:\SOFTWARE\Microsoft\Deployment 4" -name "TPM Present During Imaging" -value "Yes"}

#endregion

#region Load Trellix Agent Managed mode files

TranscriptSectionHeader -HeaderName "Load Trellix Agent Managed mode files"

# this set of six files is used to convert Trellix Agent from Unmanaged into Managed mode, and is used by StartEncryption script
CopyFile -Source "$ScriptRoot\Applications\Trellix Agent\Source\FramePkg.exe"      -Destination "C:\ProgramData\McAfee\Agent"
CopyFile -Source "$ScriptRoot\Applications\Trellix Agent\Source\SiteList.xml"      -Destination "C:\ProgramData\McAfee\Agent"
CopyFile -Source "$ScriptRoot\Applications\Trellix Agent\Source\srpubkey.bin"      -Destination "C:\ProgramData\McAfee\Agent"
CopyFile -Source "$ScriptRoot\Applications\Trellix Agent\Source\reqseckey.bin"     -Destination "C:\ProgramData\McAfee\Agent"
CopyFile -Source "$ScriptRoot\Applications\Trellix Agent\Source\req2048seckey.bin" -Destination "C:\ProgramData\McAfee\Agent"
CopyFile -Source "$ScriptRoot\Applications\Trellix Agent\Source\sr2048pubkey.bin"  -Destination "C:\ProgramData\McAfee\Agent"

#endregion

#region Verifying encryption status - Rev. 02/18/2023

CheckTrellixDir
GetTPMstatus
GetBitlockerVol
GetBitlockerVolumeStatus

#endregion

#region System Info - Expanded version - Rev. 12/15/2022

TranscriptSectionHeader -HeaderName "System Info - Expanded version"                                                                     

# DEVICE ##################################################################
Write-Host "---- Device info"
$Timestamp = Get-Date -format "yyyy-MM-dd hh-mmtt"
$ComputerName = $env:computername

Write-Host "Date"                                                                   
Write-Host "     $Timestamp"                                                        
Write-Host ""                                                                       
Write-Host "Device"                                                                 
Write-Host "     $ComputerName"                                                     

$WMICS  = gwmi win32_ComputerSystem
$WMIBI  = gwmi win32_bios
$WMIBB  = gwmi win32_baseboard | Select -Property *

# make model and serial number for standard computer
           $Make = $WMICS.Manufacturer
          $Model = $WMICS.Model
   $SerialNumber = $WMIBI.SerialNumber

# make model and serial number for Intel NUC computer (non-standard WMI)
        $NUCmake = $WMIBB.Manufacturer
       $NUCmodel = $WMIBB.Product
$NUCserialNumber = $WMIBB.SerialNumber

# make model and serial number
If ($NUCmake -eq "Intel Corporation")
{
Write-Host "          $NUCmake $NUCmodel"                                          
Write-Host "          sn: $NUCserialNumber"                                        
}
Else
{
Write-Host "          $Make $Model"                                                
Write-Host "          sn: $SerialNumber"                                           
}

# BIOS ######################################################################
Write-Host "---- BIOS info"
$BiosVersion1 = $WMIBI.Name
$BiosVersion2 = $WMIBI.SMBIOSBIOSVersion
$BiosReleaseDate1  = $WMIBI.ReleaseDate
$BiosReleaseDate2  = [Management.ManagementDateTimeConverter]::ToDateTime($BiosReleaseDate1)
$BiosReleaseDate   = $BiosReleaseDate2.ToShortDateString()


If ($Model -eq "Virtual Machine") {Write-Host "          BIOS Version: MS Hyper-V VM BIOS $BiosVersion2"}
                             Else {Write-Host "          BIOS Version: $BiosVersion1"                   }

Write-Host "          BIOS Release Date: $BiosReleaseDate"                         

# OPERATING SYSTEM #########################################################
Write-Host "---- OS info"
$WMIOS  = gwmi win32_OperatingSystem
$OS = $WMIOS.Caption
$BN = $WMIOS.BuildNumber
$SP = $WMIOS.csdversion
$InstDate1 = $WMIOS.InstallDate
$InstDate2 = [Management.ManagementDateTimeConverter]::ToDateTime($InstDate1)
$InstDate   = $InstDate2.ToShortDateString()
$ProdKey = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey # getting OS product key info

Write-Host ""                                                                      
Write-Host "OS"                                                                    
Write-Host "     $OS"                                                              
If ($BN -ne $NULL) {Write-Host "          Build Number   : $BN"                    }
If ($SP -ne $NULL) {Write-Host "          Service Pack   : $SP"                    }
Write-Host "          Deployment Date: $InstDate"                                  
If ($ProdKey -ne $NULL) {Write-Host "          Product Key    : $ProdKey"          }


# CPU ########################################################################
Write-Host "---- CPU info"
Write-Host ""                                                                      
Write-Host "CPU"                                                                   

$WMIPC  = gwmi Win32_Processor
ForEach ($CPU in $WMIPC) {

$Processor  = $CPU.Name
$ProcNumber = $CPU.DeviceID
$ProcCores  = $CPU.NumberOfCores

Write-Host "     $ProcNumber $Processor $ProcCores Cores"                          
}

# MEMORY #####################################################################
Write-Host "---- Memory info"
$Memory1 = $WMICS.TotalPhysicalMemory / 1GB
$Memory2 = [math]::Round($Memory1)

Write-Host ""                                                                      
Write-Host "RAM"                                                                   
Write-Host "     $Memory2 GB Total"                                                

$WMIRAM = gwmi Win32_PhysicalMemory
ForEach ($RAMmodule in $WMIRAM) {

$RAMmoduleManufacturer  = $RAMmodule.Manufacturer
$RAMmoduleBankNumber    = $RAMmodule.BankLabel
$RAMmodulePartNumber    = ($RAMmodule.PartNumber).Trim()
$RAMmoduleDeviceLocator = $RAMmodule.DeviceLocator
$RAMmoduleSerialNumber  = $RAMmodule.SerialNumber
$RAMmoduleSpeed         = $RAMmodule.Speed
$RAMmoduleCapacity1     = $RAMmodule.Capacity / 1GB
$RAMmoduleCapacity2     = [math]::Round($RAMmoduleCapacity1)

If ($RAMmoduleSerialNumber -ne $NULL) { Write-Host "          $RAMmoduleBankNumber : $RAMmoduleDeviceLocator  $RAMmoduleManufacturer  $RAMmodulePartNumber  $RAMmoduleCapacity2 GB  $RAMmoduleSpeed MHz  sn: $RAMmoduleSerialNumber"}
Else { Write-Host "          $RAMmoduleBankNumber : $RAMmoduleDeviceLocator  $RAMmoduleManufacturer  $RAMmodulePartNumber  $RAMmoduleCapacity2 GB  $RAMmoduleSpeed MHz"                                                             }
}

# GRAPHICS ###################################################################
Write-Host "---- Graphics info"
Write-Host ""                                                                      
Write-Host "Graphics"                                                              

$WMIGFX = gwmi Win32_VideoController
ForEach ($GFX in $WMIGFX) {

$GFXName           = $GFX.Name
$GFXDriverDate1    = $GFX.DriverDate
$GFXDriverDate2    = [Management.ManagementDateTimeConverter]::ToDateTime($GFXDriverDate1)
$GFXDriverDate     = $GFXDriverDate2.ToShortDateString()
$GFXAdapterRAM1    = $GFX.AdapterRAM / 1GB
$GFXAdapterRAM2    = [math]::Round($GFXAdapterRAM1,2)
$GFXDriverVersion  = $GFX.DriverVersion
$GFXVideoModeDesc  = $GFX.VideoModeDescription

If ($GFXName -ne $NULL)          {Write-Host "     $GFXName "                                  }
If ($GFXAdapterRAM2 -ne $NULL)   {Write-Host "          Video Memory: $GFXAdapterRAM2 GB Total"}
If ($GFXVideoModeDesc -ne $NULL) {Write-Host "          Graphic Mode: $GFXVideoModeDesc"       }
If ($GFXDriverVersion -ne $NULL) {Write-Host "          Driver Ver  : $GFXDriverVersion"       }
If ($GFXDriverDate -ne $NULL)    {Write-Host "          Driver Date : $GFXDriverDate"          }
Write-Host ""                                                                                 
}

# MONITOR ##################################################################
# https://edid.tv/manufacturer/ # to decode Manufacturer name code
Write-Host "---- Display info"
Write-Host "Display"                                                               

$Monitors = Get-WmiObject WmiMonitorID -Namespace root\wmi
    
function Decode { If ($args[0] -is [System.Array]) {[System.Text.Encoding]::ASCII.GetString($args[0])}
            Else { "Not Found"}}
    
ForEach ($Monitor in $Monitors) {  
     $Manufacturer = Decode $Monitor.ManufacturerName -notmatch 0
     $Name         = Decode $Monitor.UserFriendlyName -notmatch 0
     $Serial       = Decode $Monitor.SerialNumberID   -notmatch 0
     Write-Host "     Manufacturer: $Manufacturer Model: $Name SN: $Serial"        
 }

# AUDIO ######################################################################
Write-Host "---- Audio info"
Write-Host ""                                                                      
Write-Host "Audio"                                                                 

$WMIAUD = gwmi Win32_SoundDevice
ForEach ($AUD in $WMIAUD) {
$AUDName = $AUD.Name
If ($AUDName -ne $NULL) {Write-Host "     $AUDName "                               }
}
If ($AUDName -eq $NULL) {Write-Host "     Not detected "                           }
Write-Host ""                                                                      

# STORAGE #####################################################################
Write-Host "---- Storage info"
Write-Host "Storage"                                                               
Write-Host "     Controller(s):"                                                   

$WMIIDE = gwmi Win32_IDEController
If ($WMIIDE) {
$WMIIDEName = $WMIIDE.Name
Write-Host "               $WMIIDEName"                                            }

$WMISCSI = gwmi Win32_SCSIController
If ($WMISCSI) {
$WMISCSIName1 = $WMISCSI.Name
$WMISCSIName  = $WMISCSIName1[0]
Write-Host "               $WMISCSIName"                                           }

Write-Host ""                                                                      
Write-Host "     Drive(s):"                                                        
$WMIDD  = gwmi win32_diskdrive
# $WMIDD  = gwmi win32_diskdrive   -Filter "InterfaceType = 'IDE' or InterfaceType = 'USB'"
ForEach ($Drive in $WMIDD) {

  $DriveMediaType = $Drive.MediaType
  $DriveInterface = $Drive.InterfaceType
      $DriveIndex = $Drive.Index
    $DriveSerial1 = $Drive.SerialNumber
      $DriveModel = $Drive.Model
      $DriveSize1 = $Drive.Size / 1GB
      $DriveSize2 = [math]::Round($DriveSize1,2)

      Write-Host "          $DriveInterface Drive Interface / $DriveMediaType / Physical Drive $DriveIndex"   

If ($DriveSerial1 -ne $NULL)
    { $DriveSerial = $DriveSerial1.trim()
      Write-Host "               $DriveSize2 GB $DriveModel SN: $DriveSerial"     }
Else {Write-Host "               $DriveSize2 GB $DriveModel"                      }
}
Write-Host ""                                                                     

# DISKS ####################################################################### 
Write-Host "---- Disk Volume info"
Write-Host "Volumes"                                                              

$WMILD  = gwmi win32_logicaldisk -Filter "DriveType = '2' or DriveType = '3'" | where {$_.DeviceID -ne "A:"}
ForEach ($LD in $WMILD) {

$LDLetter = $LD.DeviceID
$LDName   = $LD.VolumeName
$LDFS     = $LD.FileSystem
$LDSize1  = $LD.Size / 1GB
$LDSize2  = [math]::Round($LDSize1,2)
$LDFreeSize1  = $LD.FreeSpace / 1GB
$LDFreeSize2  = [math]::Round($LDFreeSize1,2)

If ($LDLetter -ne $NULL)    {Write-Host "     Letter: $LDLetter"                  }
If ($LDName -ne $NULL)      {Write-Host "          Name   : $LDName"              }
                    Else    {Write-Host "          Name   : Not found"            }
If ($LDFS -ne $NULL)        {Write-Host "          FileSys: $LDFS"                }
If ($LDSize2 -ne $NULL)     {Write-Host "          Size   : $LDSize2 GB"          }
If ($LDFreeSize2 -ne $NULL) {Write-Host "          Free   : $LDFreeSize2 GB"      }
If ($LDLetter -ne $NULL)    {Write-Host ""                                        }
}

# NETWORK ADAPTER LIST ###########################################################
Write-Host "---- Network Adapter info"
Write-Host "Network Adapter List"                                                 

$WMINA  = gwmi Win32_NetworkAdapter | where{$_.PhysicalAdapter -eq "True"}
ForEach ($Adapter in $WMINA) {

$AdapterName  = $Adapter.Name
If ($AdapterName -ne "Bluetooth Device (Personal Area Network)") {Write-Host "     $AdapterName"}
}
Write-Host ""                                                                     

# ACTIVE NETWORK ADAPTERS #########################################################
Write-Host "---- Active Network Adapter info"
Write-Host "Active Network Adapters"                                              

$WMINIC = gwmi win32_NetworkAdapterConfiguration | where{$_.IPEnabled -eq "True"}
ForEach ($NIC in $WMINIC) {

$NICDescription      = $NIC.Description
$NICIPaddress        = $NIC.IPaddress[0]
$NICMACAddress       = $NIC.MACAddress
$NICIPSubnet         = $NIC.IPSubnet
$NICDefaultIPGateway = $NIC.DefaultIPGateway
$NICspeed            = ((gwmi Win32_NetworkAdapter | where{$_.Name -eq $NICDescription}).Speed) / 1e+6 # Bps to Mbps convertion formula

Write-Host "     $NICDescription"                                                
Write-Host "          IP     : $NICIPaddress"                                    
Write-Host "          MAC    : $NICMACAddress"                                   
Write-Host "          Subnet : $NICIPSubnet"                                     
If ($NICDefaultIPGateway -ne $NULL) {Write-Host "          Gateway: $NICDefaultIPGateway"}
                               Else {Write-Host "          Gateway: Not detected"}
Write-Host "          Speed  : $NICspeed Mbps"                                   
Write-Host ""                                                                    
}

#endregion

#region Capturing list of installed apps - Rev. 02/17/2023

#Get-RemoteProgram -Property Publisher,InstallDate,DisplayVersion,InstallSource,SystemComponent,Uninstallstring | Sort-Object ProgramName  | Export-CSV "C:\Windows\Logs\CHOA\Installed Apps List $Timestamp.csv" -notype

#endregion

#region  Tasks common to all images

TranscriptSectionHeader -HeaderName "Tasks common to all images"

# Verifying that image type info is written to the registry
Write-Host "Verifying that image type info is written to the registry"

$ImgTypeRegCheck = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Deployment 4" | Select -ExpandProperty "ImageType"

Write-Host ""
Write-Host "-- registry value currently: $ImgTypeRegCheck"
Write-Host ""

If ($ImgTypeRegCheck -ne $ImageType) { Set-Itemproperty -path "HKLM:\SOFTWARE\Microsoft\Deployment 4" -name "ImageType" -value "$ImageType" 
                                       $ImgTypeRegCheck = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Deployment 4" | Select -ExpandProperty "ImageType"
                                       Write-Host "-- registry value currently: $ImgTypeRegCheck"
}


# Disable OneDrive Auto-Update Scheduled Task - need to make Function for it
$ST1status = Get-ScheduledTask -TaskName "*OneDrive*"
$ST1name   = $ST1status.TaskName
$ST1state  = $ST1status.State

If ($ST1state -like "Disabled") { Write-Host "-- $ST1name is already set to Disabled!" }

Else {
        Write-Host "$ST1name current state: $ST1state"
        Write-Host "-- disabling scheduled task"
        Write-Host ""

        $GST = Get-ScheduledTask -TaskName "*OneDrive*" | Disable-ScheduledTask
        Start-Sleep 10

        $ST1status = Get-ScheduledTask -TaskName "*OneDrive*"
        $ST1name   = $ST1status.TaskName
        $ST1state  = $ST1status.State
        Write-Host "$ST1name current state: $ST1state"
     }




# Disable Adobe Auto-Update Scheduled Task - need to make Function for it
$ST2status = Get-ScheduledTask -TaskName "*Adobe*"
$ST2name   = $ST2status.TaskName
$ST2state  = $ST2status.State

If ($ST2state -like "Disabled") { Write-Host "-- $ST2name is already set to Disabled!" }

Else {
        Write-Host "$ST2name current state: $ST2state"
        Write-Host "-- disabling scheduled task"
        Write-Host ""

        $GST = Get-ScheduledTask -TaskName "*Adobe*" | Disable-ScheduledTask
        Start-Sleep 10

        $ST2status = Get-ScheduledTask -TaskName "*Adobe*"
        $ST2name   = $ST2status.TaskName
        $ST2state  = $ST2status.State
        Write-Host "$ST2name current state: $ST2state"
     }




#endregion



#region  DisplayPC image type tasks
If ($ImageType -eq "DisplayPC") {

TranscriptSectionHeader -HeaderName "DisplayPC image type tasks"

#Set-Itemproperty -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" `
#                 -name "SSObuild" `
#                 -value "Powershell.exe -ExecutionPolicy ByPass -WindowStyle Maximized -File C:\Users\Public\Autologon1.ps1"


CopyFile -Source "$ScriptPath\Autologon.exe"       -Destination "C:\Users\Public"
CopyFile -Source "$ScriptPath\kioskRunOnce.ps1"    -Destination "C:\Users\Public"
#CopyFile -Source "$ScriptPath\Autologon1.ps1"       -Destination "C:\Users\Public"
#CopyFile -Source "$ScriptPath\Autologon2.ps1"       -Destination "C:\Users\Public"

#$runOnceReg = Test-RegistryValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" "SSObuild" 
#if ($runOnceReg -eq $true){
#    write-host "The RunOnce key has been set."
#}else{
#    write-host "The RunOnce key has NOT been set."
#}

CopyFile -Source "$ScriptPath\wallpaper10std.bmp" -Destination "C:\Windows\Web\Wallpaper\CHOA"
$imgPath="C:\Windows\Web\Wallpaper\CHOA\Wallpaper10std.bmp"
SetWallpaper -imgPath $imgPath

#DeleteItem -FilePath "C:\Users\Public\Desktop\Children's Application Portal.url"

} # DisplayPC case end
#endregion


#region Cleanup tasks - Rev. 02/18/2023

TranscriptSectionHeader -HeaderName "Cleanup Tasks"

# CopyFolder -Source "C:\Windows\Temp\DeploymentLogs" -Destination "C:\Windows\Logs\CHOA"

# Write-Host ""

# MoveItem -Source "C:\Users\Administrator\AppData\Local\Temp\bcdtest.txt"        -Destination "C:\Windows\Logs\CHOA"
# MoveItem -Source "C:\Users\Administrator\AppData\Local\Temp\Results.xml"        -Destination "C:\Windows\Logs\CHOA"
# MoveItem -Source "C:\Users\Administrator\AppData\Local\Temp\SMSTSLog\smsts.log" -Destination "C:\Windows\Logs\CHOA"
# MoveItem -Source "C:\Users\Administrator\AppData\Local\Temp\smsts.log"          -Destination "C:\Windows\Logs\CHOA\DeploymentLogs"

# Write-Host ""

CreateFolder -ItemPath "C:\Windows\Logs\CHOA\App Install Logs"
CreateFolder -ItemPath "C:\Windows\Logs\CHOA\DeploymentLogs"

Write-Host ""

MoveFileType -Source "C:\Users\Public"                    -Destination "C:\Windows\Logs\CHOA\App Install Logs" -FileExtension "log"

Write-Host ""

CopyFile -Source "$ScriptPath\Log File Reader.lnk"        -Destination "C:\Windows\Logs\CHOA"
CopyFile -Source "$ScriptPath\MDT Deployment Logs.lnk"    -Destination "C:\Windows\Logs\CHOA"
CopyFile -Source "$ScriptPath\MDT Imaging Result XML.lnk" -Destination "C:\Windows\Logs\CHOA"
CopyFile -Source "$ScriptPath\MDT Task Seq Log.lnk"       -Destination "C:\Windows\Logs\CHOA"
CopyFile -Source "$ScriptPath\Domain join log.lnk"        -Destination "C:\Windows\Logs\CHOA"

# Copy Deployment Logs to CHOA Logs
CopyFile -Source "C:\Users\Administrator\AppData\Local\Temp\SMSTSLog\smsts.log"        -Destination "C:\Windows\Logs\CHOA\DeploymentLogs"
Write-Host ""
CopyFileType -Source "C:\MININT\SMSOSD\OSDLOGS" -Destination "C:\Windows\Logs\CHOA\DeploymentLogs" -FileExtension "log"

Write-Host ""

CopyFolder -Source "C:\Users\Administrator\AppData\Local\Temp\McAfeeLogs" -Destination "C:\Windows\Logs\CHOA\App Install Logs"

Write-Host ""

DeleteItem -FilePath "C:\Windows\BGInfo.bmp"
DeleteItem -FilePath "C:\Windows\Education.xml"
DeleteItem -FilePath "C:\Windows\IoTEnterprise.xml"
DeleteItem -FilePath "C:\Windows\Professional.xml"
DeleteItem -FilePath "C:\Windows\ProfessionalCountrySpecific.xml"
DeleteItem -FilePath "C:\Windows\ProfessionalEducation.xml"
DeleteItem -FilePath "C:\Windows\ProfessionalSingleLanguage.xml"
DeleteItem -FilePath "C:\Windows\ProfessionalWorkstation.xml"
DeleteItem -FilePath "C:\Windows\ServerRdsh.xml"
DeleteItem -FilePath "C:\Windows\BGInfo.bmp"

Write-Host ""

# DeleteItem -FolderPath "C:\Users\Administrator\AppData\Local\Temp\SMSTSLog"
# DeleteItem -FolderPath "C:\Users\Administrator\AppData\Local\Temp\Tools"
# DeleteItem -FolderPath "C:\Windows\Temp\DeploymentLogs"

#endregion

#region List folder contents

TranscriptSectionHeader -HeaderName "List folder contents"

ListFolderContents -FolderPath "C:\Windows\Logs\CHOA"
ListFolderContents -FolderPath "C:\Windows\Logs\CHOA\DeploymentLogs"
ListFolderContents -FolderPath "C:\Users\Public"
ListFolderContents -FolderPath "C:\Users\Administrator\Desktop"
ListFolderContents -FolderPath "C:\Users\Administrator\AppData\Local\Temp"
ListFolderContents -FolderPath "C:\Windows\Temp"

#endregion

#region check Trellix Agent status and run forced refresh if still Unmanaged

$cmdagentinfolog = "C:\Users\Public\cmdagentinfo.log"

If ( Test-Path $cmdagentinfolog ) { 

$Result = Select-String -Path $cmdagentinfolog -Pattern "AgentMode:" -CaseSensitive -SimpleMatch 

[string]$ResultRead = $Result.Line

If ($ResultRead -match 'AgentMode: 1') {
                                          Write-Host "Trellix Agent is in Managed Mode!"
                                       }

Else {  
        TranscriptSectionHeader -HeaderName "Trellix Agent Forced Refresh last attempt"
        
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



#endregion

Write-Host ""

If ($Error) { Write-Host "Reported error: $Error"
              $Error.Clear()}
Else        { Write-Host "No errors reported by this script!"}

Write-Host ""

stop-transcript

exit 0