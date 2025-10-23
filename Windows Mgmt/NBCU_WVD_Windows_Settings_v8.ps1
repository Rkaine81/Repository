<#
Script Name: NBCU_WVD_Windows_Settings_v8.ps1
Script Version: 8.5
Author: Adam Eaddy
Edited by: Adam Eaddy
Date Created: 16/04/2021
Date Updated: 06/03/2022
Description: The purpose of this script is to run an initial setup of a WVD device.  This will configure Computer and User settings.
Changes:

v1.2 - added check for software installations hanging.  Kills install after X mins.
v1.2 - modularize the script.  Can can COMPUTERSETTINGS / USERSETTINGS / APPLICATIONS to only install the respective portion of the script. 
v1.3 - Add function for SMB file copy. 
v1.3 - Added section to copy files to local device c:\Temp directory.
v1.3 - Update softwre download URLs.
v1.3 - Added parameter for "App install switches" in the install-apps function.
v1.3 - Added function to import power config
v1.4 - Updated file paths to point to prod file repo.
v1.4 - Added Reg key for teams installer
v1.4 - Added lines to download FSLogix and Teams installs
v1.5 - Add MS Office and OneDrive to app install
v1.5 - BUG FIX - Moving "wait" functionality out of app install function, and moving it to the loop through the array of applications.
v2.0 - Modified major version number for tracking purposes.
v3.0 - Final script modifications made to installer paths and file names.  
v4.0 - Cleanup installer files (lines: 134-152)
v4.1 - Create post app install registry section (Lines: 997-1023)
v4.1 - Fixed bug with wallpaper config (Lines: 612)
v4.2 - Remove o365/OneDrive and Webex from downloads and app install. (Section: Download Core Apps, Install Core Apps)
v4.2 - Modify get web-files function to use start-bitstransfer instead of curl for substantially faster download speeds. (Lines: 350)
v4.3 - Add Qualys install
v5.0 - Add HyperV install
v5.0 - Install .Net as a Windows feature with HyperV.  Removed EXE installer.
v5.1 - Remove Windows Applications
v5.2 - Add AppVentiX installer
v5.2 - Commented out lines for downloading and installing: Chrome, FireFox, and ReaderDC
v5.2 - Add VMWare Desktop Optimazation tool.  Download files and run exe.
v5.3 - Add reg key for Chrome audio fix
v5.3 - Modify cleanup and remove parameter.
v5.3 - Added Region Parameter for East/West setup. (Set TimeZone and AppVentiX Path)
v5.3 - Add function for changing Windows Service service-account
v5.3 - Add section for adding local users to local groups
v5.4 - Remove Qualys
v5.4 - Add Edge Fix registry entries
v6.0 - Set AppVentiX path to Azure East
v6.0 - Removed regional settings
v6.0 - Copy ADMX and ADML files to local policy store
v6.0 - Create Function to import reg keys
v6.0 - Add "Personalization Options to Control Panel via registry import
v6.0 - Create function to remove files and add Adobe Flash file paths (Qualys)
v6.0 - Add reg key creation for Qualys fixes
v6.0 - Add function to rename files
v6.0 - Renamed Chrome and Edge update files to disable update.
v6.0 - Changed website URL from ECLAPWP00555 to ECLAPWP00556
v6.1 - Added Edge install
v7.0 - Added first run logic for first run script.  Create new directory (c:\qualys), copy qualys installer.  Copy WVDConfig.inf to C:\Temp. Create new dir (c:\runonce), copy runonce script into runonce dir.  
v7.1 - Added logic to create runonce scheduled task to run first run script.
v7.2 - Updated credential process.
v7.3 - Add new applications to build - RAST Tools, 7-Zip, iNews
v7.3 - Add registry key for image version tagging
v7.4 - Add Function "Set-WindowsCapabilities" to utilize Add-WindowsCapability CMDlet - RSAT Tools
v7.4 - Add Function "Set-PSREmoting" to enable or disable PowerShell Remoting.
v7.5 - Add WVD Help url link to public desktop
v7.5 - Add SCCM client installer to C:\Temp
v8.0 - Major Changes. Reduced logging data and cleaned up messages. Disable Schedule Task at creation.  Add new applications: SAP/iNews/Dali/SMSS/SCCM/VisioViewer/OneDrive/o365/PowerBIDesktop/.  Fix AppVentiX Service Account.  Added SCCM installer.  Install Telnet.  Feature Function using DISM.  Add IE icon to desktop.  Install Az and WindowsUpdate PS module.
v8.1 - Added new office files
v8.2 - Added line to disable Windows Defender in registry. Computer registry setting (To address builds being slow)
v8.3 - Added: Program blacklist via registry.  Disable Updater schedule tasks.  Disable Updater Services. Add new office and Java.   
v8.4 - Removed BPC installer and comment out Java
v8.5 - Added Java in App Section. Disable Windows Service for Chrome, Firefox, Adobe, and Citrix auto updates in Computer Settings section. Add "Disallow" USER reg keys for pangpa.exe / openvpn.exe / openvpn-gui.exe in User Settings section.  Updated SCCM client install in Cleanup Section. Install IBM iAccess, SecurePrint Drivers, and Promenta Excel Add-On in App Section. New Function to Disable Scheduled Task for Adobe and Google Updates in post App Config Section.


Examples:
To run everything: .\NBCU_WVD_Windows_Settings_v2.ps1 -COMPUTERSETTINGS true -USERSETTINGS true -APPLICATIONS true -CLEANUP  true -NBCImageTag WVD20H2-01221E1

To run everything except applications: .\NBCU_WVD_Windows_Settings_v2.ps1 -COMPUTERSETTINGS true -USERSETTINGS true -APPLICATIONS false -CLEANUP  true -NBCImageTag WVD20H2-01221E1

To run Computer Settings only: .\NBCU_WVD_Windows_Settings_v2.ps1 -COMPUTERSETTINGS true -USERSETTINGS false -APPLICATIONS false -CLEANUP  true -NBCImageTag WVD20H2-01221E1

/#>

    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('true', 'false')]
        [string]$COMPUTERSETTINGS,
        [Parameter(Mandatory=$true)]
        [ValidateSet('true', 'false')]
        [string]$USERSETTINGS,
        [Parameter(Mandatory=$true)]
        [ValidateSet('true', 'false')]
        [string]$APPLICATIONS,
        [Parameter(Mandatory=$true)]
        [ValidateSet('true', 'false')]
        [string]$CLEANUP,
        [Parameter(Mandatory=$false)]
        [string]$NBCImageTag
    
    )



#region FUNCTIONS


#Logging Function
#Example: Write-Log "This is a log entry."
Function Write-Log {

    param(
        [Parameter(Mandatory=$true)]
        [string]$VALUE
    )

    $SDATE = get-date -Format MMddyyyy
    $LOGPATH = $env:TEMP
    #Set Log name
    $LOGFILE = "PCPrep_$SDATE.log"
    $FULLLOGPATH = "$LOGPATH\$LOGFILE"

    write-output "$(get-date): $VALUE" | out-file $FULLLOGPATH -Append -Force -NoClobber

}


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


#Set Windows Service states. Start/Stop services and Set Start type.
#Example: Check-Service -SERVICE "AdobeARMservice" -STARTTYPE Automatic -ACTION Start
function Check-Service {

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

        
    if ($ACTION -eq "Stop") {$STATUS = "Stopped"} 
    if ($ACTION -eq "Start") {$STATUS = "Running"} 

    Write-output "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-output "The current Service state for $SERVICE is: $($(get-service $SERVICE).Status)."
    if ($(get-service $SERVICE).Status -ne $STATUS ) {Write-output "Attempting to $ACTION the Service: $SERVICE."}

    if ((get-service $SERVICE).Status -ne $STATUS -and $ACTION -eq "Start") {Start-Service -Name $SERVICE}
    if ((get-service $SERVICE).Status -ne $STATUS -and $ACTION -eq "Stop") {Stop-Service -Name $SERVICE}

    if ((get-service $SERVICE).Status -eq $STATUS) {Write-Log "The Service State for $SERVICE is set to: $($(get-service $SERVICE).Status)."} else {Write-Log "Warning: The Service State for $SERVICE could not be changed." ; $ERROR = "1"}



    Write-output "The current Service startup type for $SERVICE is: $($(get-service $SERVICE).StartType)."
    if ($(get-service $SERVICE).StartType -ne $STARTTYPE ) {Write-output "Attempting to set the Service startup type to $STARTTYPE for: $SERVICE."}

    if ((get-service $SERVICE).StartType -ne $STARTTYPE) {Set-Service -Name $SERVICE -StartupType $STARTTYPE}
        start-sleep 3
    if ((get-service $SERVICE).StartType -eq $STARTTYPE) {Write-output "The Startup Type for $SERVICE is set to $($(get-service $SERVICE).StartType)." } else {Write-Log "Warning: The Startup Type for $SERVICE could not be changed."}


    if ($ERROR -eq "1") {
        Write-output "The current Service state for $SERVICE is still: $($(get-service $SERVICE).Status)."
        Write-output "Attempting to $ACTION the Service again: $SERVICE."

            if ($ACTION -eq "Stop") {$STATUS = "Stopped"} 
            if ($ACTION -eq "Start") {$STATUS = "Running"} 

            if ((get-service $SERVICE).Status -ne $STATUS -and $ACTION -eq "Start") {Start-Service -Name $SERVICE}
            if ((get-service $SERVICE).Status -ne $STATUS -and $ACTION -eq "Stop") {Stop-Service -Name $SERVICE}

            if ((get-service $SERVICE).Status -eq $STATUS) {Write-output "The Service State for $SERVICE is set to $($(get-service $SERVICE).Status)."} else {Write-Log "Error: The Service State for $SERVICE could not be changed."}
    }
}


#Create registry path if it doesn't exist. Modify entry value. 
#Example: Write-RegKey "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" "DWord" "1"
 Function Write-RegKey{
 
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
    

        
    Write-output "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-output "Checking for the Registry key: $registryPath\$regName."
    If(!(Test-RegistryValue $registryPath $regName)){Write-output "Attempting to write RegKey: $registryPath\$regName"}

    If(!(Test-Path $registryPath)){
        Write-output "Attempting to write RegKey: $registryPath."
        New-Item -Path $registryPath -Force
            If(Test-Path $registryPath){Write-output "RegKey: $registryPath exists."}else{Write-Log "Error: The reg key $registryPath could not be created."}
    }

    $WRCHECK = $null
    if (((Get-ItemProperty -Path $registryPath -Name $regName).$regname) -ne $regValue) {
        Write-Output "The Registry Value data does not match the required data value.  Settings the data value to: $regValue"
        New-ItemProperty -Path $registryPath -Name $regName -PropertyType $regType -Value $regValue -Force | Write-Output
        $WRCHECK = "1"
    }else{
        Write-output "The registry value is already set to $regValue."
    }


    if ($WRCHECK = "1"){
        if (((Get-ItemProperty -Path $registryPath -Name $regName).$regname) -eq $regValue) {
            Write-output "The Registry Value data is set to: $regValue"
        }else{
            Write-Log "Error: The registry value data could not be set for $regName."
        }
    }
    
}


#Remove registry item if it exists
#Example: Remove-RegKey "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo"
 Function Remove-RegKey{
 
    Param(
        [Parameter(Mandatory=$true)]
        [string]$registryPath,
        [Parameter(Mandatory=$true)]
        [string]$regName
    )
    

    Write-Output "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Output "Attempting to remove the Registry key: $registryPath\$regName."
    If((Test-RegistryValue $registryPath $regName)){
        Write-Output "Attempting to remove the registry key value: $regname."
        Remove-ItemProperty -Path $registryPath -Name $regName -Force | Write-output
    }
        
    If(!(Test-RegistryValue $registryPath $regName)){
        Write-output "The registry key value: $regname is not present."
            
    }else{

        Write-Log "Error: Could not remove registry key value: $regname."

    }
    
}


#Create Directory and Grant Full Control
#Example: Create-Dir "C:\temp15" "Power Users"
Function Create-Dir {

    param(
        [Parameter(Mandatory=$true)]
        [string]$NEWDIRPATH,

        [Parameter(Mandatory=$true)]
        [string]$ACCOUNTTOADD
    
    )



        Write-Output "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
        Write-Output "Checking to see if the directory exists: $NEWDIRPATH."

        #Create Temp directory and 'Set Power Users' to Full Control
            if (!(test-path $NEWDIRPATH)) {

                Write-Output "The directory does not exist. Creating directory: $NEWDIRPATH."       
                new-item -Path $NEWDIRPATH -ItemType Directory
                $DIR1 = get-item $NEWDIRPATH
                
                if (test-path $NEWDIRPATH) {
                    Write-output "The directory was created successfully."
                }else{
                    Write-Log "Error: Could not create the directory."
                }

            }

        #Add Full Control
      
        Write-Output "Adding permissions for: $ACCOUNTTOADD."

            $ACL = Get-ACL -Path $DIR1.FullName
            $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($ACCOUNTTOADD,"FullControl","Allow")
            $ACL.SetAccessRule($AccessRule)
            $ACL | Set-Acl -Path $DIR1.FullName
            $ACLCHECK = (Get-ACL -Path $($DIR1.FullName)).Access | where {$_.IdentityReference -like "*$ACCOUNTTOADD*"}             

            if (($ACLCHECK.IdentityReference) -like "*$ACCOUNTTOADD*") {
                Write-output "Successfully added permissions for $ACCOUNTTOADD to $NEWDIRPATH."
            }else{
                Write-Log "Could not add permissions for $ACCOUNTTOADD to $NEWDIRPATH."
            }

}


#Download EXE into install directory
#Example: Get-App -APPINSTALLPATH "C:\Install\HDTools" -APPURL "http://core.inbcu.com/downloads/whoami_installer_4.exe"
Function Get-WebFiles {

    param(
        [Parameter(Mandatory=$true)]
        [string]$APPURL,

        [Parameter(Mandatory=$true)]
        [string]$APPINSTALLPATH
    
    )



        #Create Install Directory 
        Write-Output "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
        Write-Output "Checking to see if the directory exists: $APPINSTALLPATH."      
            if (!(test-path $APPINSTALLPATH)) {
                new-item -Path $APPINSTALLPATH -ItemType Directory
                Write-Output "Creating the directory: $APPINSTALLPATH."
                if ((test-path $APPINSTALLPATH)){
                    Write-Output "Successfully created the directory."
                }else{
                    Write-Log "Error: Failed to create install directory $APPINSTALLPATH."
                }
            }else{

                Write-Log "Warning: The directory $APPINSTALLPATH already exists."

            }


        #Download File into Install Directory
        $APPNAME = split-path $APPURL -Leaf
        Write-Output "Attemping to download the file $APPNAME to: $APPINSTALLPATH." 
            
            if (!(test-path "$APPINSTALLPATH\$APPNAME")) {
                Write-Output "Downloading $APPNAME to $APPINSTALLPATH."
               Start-BitsTransfer -Source $APPURL -Destination $APPINSTALLPATH
                if ((test-path "$APPINSTALLPATH\$APPNAME")) {
                    Write-Output "Successfully downloaded the file $APPNAME to $APPINSTALLPATH."
                }else{
                    Write-Log "Could not download the file $APPNAME to $APPINSTALLPATH. This could be a problem downloading the file or accessing the directory."
                }

            }else{
                Write-Log "Warning: The file $APPNAME already exists in $APPINSTALLPATH."
            }

}


#Install EXE file. Will kill install process after X minutes.
#Example: Install-Apps -APPINSTALLPATH "C:\Install" -MINUTESTOWAIT 10 -APPPARAM "/D:C"
Function Install-CoreApps {

    param(
        [Parameter(Mandatory=$true)]
        [string]$APPINSTALLPATH,
        [Parameter(Mandatory=$true)]
        [int]$SECONDSTOWAIT,
        [Parameter(Mandatory=$true)]
        [string]$APPPARAM
    
    )

    

    Write-Output "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Output "Beginning the installation of the Application(s)."



        $APP = Get-ChildItem -Path $APPINSTALLPATH | where {$_ -like "*.EXE" -or $_ -like "*.msi"}


            Write-Output "Installing $($APP.Name)."
                
            if ($APP.Name -like "*.msi") {

                Write-Output "MSI: $($APP.Name)"
                Write-Output "$(get-date)"
                start-process msiexec.exe -ArgumentList "/i $(($APP).Fullname) $($APPPARAM)"

                }elseif ($APP.Name -like "*.EXE"){

                #Start-Process $APP.FullName -argumentlist "/D:C" -wait
                Write-Output "EXE: $($APP.Name)"
                Write-Output "$(get-date)"
                Start-Process $APP.FullName -argumentlist $APPPARAM
              
                }                           

                #Write-Log "Please check C:\USGDAT for application install logs."  

}


#Configure Firewall Settings
#Example: Set-FWRules "Network Discovery" "True" "Any"
Function Set-FWRules{

    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('File And Printer Sharing','Network Discovery')]
        [string]$DGROUP,
        [Parameter(Mandatory=$true)]
        [ValidateSet('True','False')]
        [string]$ENABLEFWR,
        [Parameter(Mandatory=$true)]
        [ValidateSet('Public','Private','Any')]
        [string]$PROFILEFW
    
    )

    Write-Output "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Output "Beginning the Firewall Rule configuration for $DGROUP, $PROFILEFW."
    Set-NetFirewallRule -DisplayGroup $DGROUP -Enabled $ENABLEFWR -Profile $PROFILEFW
    $FWR = $null
    $FWR = Get-NetFirewallRule -DisplayName $DGROUP
    if ($FWR -ne $null) {
        Write-Output "Completed the Firewall Rule configuration for $DGROUP, $PROFILEFW."
    }else{
        Write-Log "Could not complete the Firewall Rule configuration for $DGROUP, $PROFILEFW."
    }

}


#Copy and apply NBCU Background
#Example: Set-NBCUWallpaper -WPPATH "C:\temp\NBCU_Wallpaper"
Function Set-NBCUWallpaper{

    param(
        [Parameter(Mandatory=$true)]
        [string]$WPPATH

    
    )

    Write-Output "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Output "Beginning the NBCU Wallpaper configuration for."


    #Take ownershipof, and remove current wallpaper files
    Write-Output "Taking ownership of the existing wallpaper files."

        takeown /f c:\windows\WEB\wallpaper\Windows\img0.jpg
        takeown /f C:\Windows\Web\4K\Wallpaper\Windows\*.*

    Write-Output "Changing the permissions of the existing wallpaper files."

        icacls c:\windows\WEB\wallpaper\Windows\img0.jpg /Grant 'Administrators:(F)'
        icacls C:\Windows\Web\4K\Wallpaper\Windows\*.* /Grant 'Administrators:(F)'

    Write-Output "Attempting to remove the existing wallpaper files."
           
        Remove-Item C:\windows\WEB\wallpaper\Windows\img0.jpg
        Remove-Item C:\Windows\Web\4K\Wallpaper\Windows\*.*
            
    Write-Output "Removed the existing wallpaper files."
                                   
        Write-Log "Copying the NBCU wallpaper files."
        Copy-Item "$WPPATH\img0.jpg" "c:\windows\WEB\wallpaper\Windows\img0.jpg"
        Copy-Item "$WPPATH\4k\*.*" "C:\Windows\Web\4K\Wallpaper\Windows"
      
    Write-Output "Completed the NBCU Wallpaper configuration."

}


#Rename Files
#Example: Copy-Files -FILESOURCEPATH "C:\Program Files (x86)\Google\Update\GoogleUpdate.exe" -FILEDESTPATH "C:\Program Files (x86)\Google\Update\GoogleUpdate_stop.exe"
Function Rename-Files {

    param(
        [Parameter(Mandatory=$true)]
        [string]$FILESOURCEPATH,
        [Parameter(Mandatory=$true)]
        [string]$FILEDESTPATH
    
    )

    Rename-Item -Path $FILESOURCEPATH -NewName $FILEDESTPATH

}


#Import Power Config
#Example: Set-PowerSettings -FILESOURCEPATH "\\wtelab-sb10\sandbox\Adam\WVD Files\startMenu.xml" -FILEDESTPATH "C:\Temp\Build\"
Function Set-PowerSettings {

    param(
        [Parameter(Mandatory=$true)]
        [string]$POWERFILEPATH
    
    )

    $FILENAME = $FILESOURCEPATH.Split("\")[-1]

    #Download File into Directory
    Write-Output "Attemping to set the NBCU Power Plan" 
    
    $POWERSETTINGS = powercfg /L
    if ($POWERSETTINGS -like "*NBCU*"){
        write-output "NBCU is present"

    }else{
        Write-output "NBCU Power Plan is not present. Importing NBCU PowerPlan and setting active."
        powercfg -import C:\temp\build\NBCUPowerPlan.pow
        $1 = Get-WmiObject -Class Win32_PowerPlan -Namespace root\cimv2\power -Filter "ElementName='NBCU Power Plan'"
        $2 = $1.InstanceID
        $3 = $2.split("\")[-1]
        $4 = $3.trim('{}')
        powercfg -setactive $4
        $POWERSETTINGS = powercfg /L  
        if ($POWERSETTINGS -like "*NBCU*"){
            Write-Output "The Power Settings were applied."
        }else{
            write-log "The power settings could not be applied."
        }
    }
}


#Modify Windows Roles and Features
#Example: Set-RolesFeatures -Action "Install" FeatureName "Microsoft-Hyper-V"
#         Set-RolesFeatures -Action "Uninstall" FeatureName "Microsoft-Hyper-V"
Function Set-RolesFeatures {

    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('Install','Uninstall')]
        [string]$Action,
        [Parameter(Mandatory=$true)]        
        [string]$FeatureRole
    
    )


    if ($Action -eq "Install"){

        Enable-WindowsOptionalFeature -Online -FeatureName $FeatureRole -All -NoRestart

    } elseif ($Action -eq "Uninstall") {

        Disable-WindowsOptionalFeature -Online -FeatureName $FeatureRole -All
    }
}


#Remove Built-in Windows Apps
#Example: Set-WindowsApps -AppName "XBox"
Function Set-WindowsApps {

    param(
        [Parameter(Mandatory=$true)]        
        [string]$AppName
    )
    

        Get-AppxPackage -Name $AppName| Remove-AppxPackage
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $AppName | Remove-AppxProvisionedPackage -Online

}


#Set Service Account for Windows Service
#Example: Set-ServiceLogon -SERVICECRED "tfayd\206687154" -SID "S-1-5-21-585568161-3286812181-671265034-2039713" -SERVICENAMETOCHANGE "AdobeARMservice" -AUTHDETAILS "abcd1234!@#$"
Function Set-ServiceLogon {

    param(
        [Parameter(Mandatory=$true)]        
        [string]$SERVICECRED,
        [Parameter(Mandatory=$true)]        
        [string]$SID,
        [Parameter(Mandatory=$true)]        
        [string]$SERVICENAMETOCHANGE,
        [Parameter(Mandatory=$true)]        
        [string]$AUTHDETAILS
    )

    

        ### Add User to SecPol Log On As A Service ###

        #The SID you want to add
        $AccountSid = $SID

        $ExportFile = 'c:\temp\CurrentConfig.inf'
        $SecDb = 'c:\temp\secedt.sdb'
        $ImportFile = 'c:\temp\NewConfig.inf'

        #Export the current configuration
        secedit /export /cfg $ExportFile

        #Find the current list of SIDs having already this right
        $CurrentServiceLogonRight = Get-Content -Path $ExportFile |
            Where-Object -FilterScript {$PSItem -match 'SeServiceLogonRight'}

#Create a new configuration file and add the new SID
$FileContent = @'
[Unicode]
Unicode=yes
[System Access]
[Event Audit]
[Registry Values]
[Version]
signature="$CHICAGO$"
Revision=1
[Profile Description]
Description=GrantLogOnAsAService security template
[Privilege Rights]
{0}*{1}
'@ -f $(
        if($CurrentServiceLogonRight){"$CurrentServiceLogonRight,"}
        else{'SeServiceLogonRight = '}
    ), $AccountSid

        Set-Content -Path $ImportFile -Value $FileContent

        #Import the new configuration 
        secedit /import /db $SecDb /cfg $ImportFile
        secedit /configure /db $SecDb


        ### Set the User for the Service ###

        Stop-Service -Name $SERVICENAMETOCHANGE
        Start-Process SC.exe -ArgumentList "config $SERVICENAMETOCHANGE obj= $SERVICECRED password= $AUTHDETAILS"
        #Start-Service -Name $SERVICENAMETOCHANGE
}


#Import Registry Files
#Example: import-regfile -RegKeyName test.reg     
Function Import-RegFile {

    param(
        [Parameter(Mandatory=$true)]        
        [string]$RegKeyName
    )
    
        regedit.exe /s $RegKeyName

}


#Cleanup Files
Function Remove-Files{

    param(
        [Parameter(Mandatory=$true)]
        [string]$FPATH

    
    )


    #Take ownershipof, and remove current wallpaper files
    Write-Output "Taking ownership of the existing files."

        takeown /f $FPATH\*.*

    Write-Output "Changing the permissions of the existing files."

        icacls $FPATH\*.* /Grant 'Administrators:(F)'

    Write-Output "Attempting to remove the existing files."
           
        Remove-Item $FPATH\*.*


}


#Add Windows capabilities
#Example: Set-WindowsCapability -CapName Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0    
Function Set-WindowsCapability {

    Param(
        [Parameter(Mandatory=$true)]
        [string]$CapName
    )

    $ServiceName = 'WUAUSERV'
    $ServiceStatus = Get-Service -Name $ServiceName
    If($ServiceStatus.Status -ne 'Running') {
        Check-Service -SERVICE "wuauserv" -STARTTYPE Manual -ACTION Start 
    }
        Write-Host "Installing Windows Capability: $CapName"      
        Add-WindowsCapability –online –Name $CapName

}


#Configures PSRemoting settings
#Examples:
#Set-PSRemoting -SetState Enable
#Set-PSRemoting -SetState Disable
Function Set-PSRemoting {

    Param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('Enable', 'Disable')]
        [string]$SetState

    )
#Write-Log 'Setting PSRemote settings'
    If ($SetState -eq 'Enable') {
    Enable-PSRemoting -Force -SkipNetworkProfileCheck
    Check-Service -SERVICE "WinRM" -STARTTYPE Automatic -ACTION Start
    } Elseif ($SetState -eq 'Disable') {
        Disable-PSRemoting -Force
        Check-Service -Service "WinRM" -STARTTYPE Disabled -ACTION Stop
    }

}

#Enable/Disable Scheduled Task
#Examples:
#Set-SchedTasks -TaskName GoogleUpdateTask -RunState Disabled
#Set-SchedTasks -TaskName GoogleUpdateTask -RunState Enabled
Function Set-SchedTasks {

    Param(
        [Parameter(Mandatory=$true)]
        [string]$TaskName,
        [Parameter(Mandatory=$true)]
        [ValidateSet('Enable', 'Disable')]
        [string]$RunState

    )
    
    
    if ($runstate -eq "disable") {
        $command = Disable-ScheduledTask -InputObject $SCHEDTASK1
    }elseif ($runstate -eq "enable") {
        $command = Enable-ScheduledTask -InputObject $SCHEDTASK1
    }

    $SCHEDTASK1 = Get-ScheduledTask -TaskName $TaskName
    if ($($SCHEDTASK1.State) -ne $runstate) {
        $command
    }

}


#endregion




#Beginning Configuration
Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
Write-Output "Beginning Configuration of $env:COMPUTERNAME."
Write-Log "Beginning Configuration of $env:COMPUTERNAME."
Write-Output "You can find the log at $FULLLOGPATH"



if ($COMPUTERSETTINGS -eq "true") {

    ### Computer Based Settings ###
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Beginning the configuration of Computer related settings."


    ### Create Core Directories and Apply Permissions ###
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Beginning the configuration of core directories."

    #  Directory   User/Group
    $CoreDirs=@(
    @("C:\Temp", "Power Users"),       #C:\Temp
    @("C:\Temp\NBCU_Wallpaper", "Power Users"),       #C:\Temp\NBCU_Wallpaper
    @("C:\Temp\NBCU_Wallpaper\4K", "Power Users"),       #C:\Temp\NBCU_Wallpaper\4K
    @("C:\USGDAT", "Power Users"),     #C:\USGDAT
    @("C:\Install", "Power Users"),    #C:\Install
    @("C:\Qualys", "Power Users"),    #C:\Qualys
    @("C:\runonce", "Power Users"),    #C:\runonce
    @("C:\Install\OSOP", "Power Users"))    #C:\Install\OSOP

        Try {
            foreach ($CoreDir in $CoreDirs) {
        
                $COREDIR00 = $CoreDir[0]
                $COREDIR01 = $CoreDir[1]

                Create-Dir -NEWDIRPATH $COREDIR00 -ACCOUNTTOADD $COREDIR01
                $COREDIR00 = $null
                $COREDIR01 = $null
 
            }
        }

        Catch{
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $FullMessage = $Error[0].Exception.GetType().FullName
                Write-Log "Error: Failed to create the new directory ($NEWDIRPATH) or add/modify the user $ACCOUNTTOADD : Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        }




    ### Aquire Files for Setup ###
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Gathering Files required for setup. (Not including application installs.)"


    #Source Path and File / Destination Path
    $FilesToDownload=@(
    @("http://eclapwp00556.tfayd.com/WVDFiles/WVDConfig.xml","C:\Temp\"),       #xml file
    @("http://eclapwp00556/WVDFirstRun/WVDRunOnce_v3.ps1","C:\runonce\"),      #ps1 file
    @("http://eclapwp00556.tfayd.com/wvdfiles/Add_Classic_Personalization_to_Control_Panel.reg","C:\Temp\Build\"),       #Reg File
    @("http://eclapwp00556.tfayd.com/wvdfiles/Add_Personalization_to_Control_Panel.reg", "C:\Temp\Build\"),              #Reg File
    @("http://eclapwp00556.tfayd.com/WVDFiles/o365SharedKey.reg", "C:\Temp\Build\"),                                     #Reg File
    @("http://eclapwp00556.tfayd.com/wvdfiles/adml/fslogix.adml","C:\Windows\PolicyDefinitions\en-US\"),                           #ADML File
    @("http://eclapwp00556.tfayd.com/wvdfiles/adml/VMware UEM FlexEngine.adml","C:\Windows\PolicyDefinitions\en-US\"),             #ADML File
    @("http://eclapwp00556.tfayd.com/wvdfiles/adml/VMware UEM Helpdesk Support Tool.adml","C:\Windows\PolicyDefinitions\en-US\"),  #ADML File
    @("http://eclapwp00556.tfayd.com/wvdfiles/adml/VMware UEM Management Console.adml","C:\Windows\PolicyDefinitions\en-US\"),     #ADML File
    @("http://eclapwp00556.tfayd.com/wvdfiles/adml/VMware UEM SyncTool COMPUTER.adml","C:\Windows\PolicyDefinitions\en-US\"),      #ADML File
    @("http://eclapwp00556.tfayd.com/wvdfiles/adml/VMware UEM SyncTool USER.adml","C:\Windows\PolicyDefinitions\en-US\"),          #ADML File
    @("http://eclapwp00556.tfayd.com/wvdfiles/adml/VMware UEM.adml","C:\Windows\PolicyDefinitions\en-US\"),                        #ADML File
    @("http://eclapwp00556.tfayd.com/wvdfiles/admx/fslogix.admx","C:\Windows\PolicyDefinitions\"),                           #ADMX File
    @("http://eclapwp00556.tfayd.com/wvdfiles/admx/VMware UEM FlexEngine.admx","C:\Windows\PolicyDefinitions\"),             #ADMX File
    @("http://eclapwp00556.tfayd.com/wvdfiles/admx/VMware UEM Helpdesk Support Tool.admx","C:\Windows\PolicyDefinitions\"),  #ADMX File
    @("http://eclapwp00556.tfayd.com/wvdfiles/admx/VMware UEM Management Console.admx","C:\Windows\PolicyDefinitions\"),     #ADMX File
    @("http://eclapwp00556.tfayd.com/wvdfiles/admx/VMware UEM SyncTool COMPUTER.admx","C:\Windows\PolicyDefinitions\"),      #ADMX File
    @("http://eclapwp00556.tfayd.com/wvdfiles/admx/VMware UEM SyncTool USER.admx","C:\Windows\PolicyDefinitions\"),          #ADMX File
    @("http://eclapwp00556.tfayd.com/wvdfiles/admx/VMware UEM.admx","C:\Windows\PolicyDefinitions\"),                        #ADMX File
    @("http://eclapwp00556.tfayd.com/WVDConfig/OSOptzTool/Selection.json","C:\Install\OSOP\"),  #VDI Config Template file
    @("http://eclapwp00556.tfayd.com/WVDConfig/OSOptzTool/Template.xml","C:\Install\OSOP\"),    #VDI Config Selection file
    @("http://eclapwp00556.tfayd.com/WVDConfig/OSOptzTool/VMwareOSOptimizationTool.exe","C:\Install\OSOP\"),             #VMWare OS Optomization tool
    @("http://eclapwp00556.tfayd.com/WVDConfig/OSOptzTool/VMwareOSOptimizationTool.exe.config","C:\Install\OSOP\"),      #VMWare OS Optomization tool config file
    @("http://eclapwp00556.tfayd.com/wvdfiles/startMenu.xml","C:\Temp\Build\"),         #Start Menu config file
    @("http://eclapwp00556.tfayd.com/wvdfiles/NBCUPowerPlan.pow","C:\Temp\Build\"),        #NBCU Power Settings config file
    @("http://eclapwp00556.tfayd.com/wvdfiles/img0.jpg","C:\Temp\NBCU_Wallpaper"),                  #NBCU Defualt wallpaper
    @("http://eclapwp00556.tfayd.com/wvdfiles/NBCU.1600x1200.jpg","C:\Temp\NBCU_Wallpaper\4K"),     #NBCU Defualt wallpaper 1600x1200
    @("http://eclapwp00556.tfayd.com/wvdfiles/NBCU.1920x1080.jpg","C:\Temp\NBCU_Wallpaper\4K"),     #NBCU Defualt wallpaper 1920x1080
    @("http://eclapwp00556.tfayd.com/wvdfiles/NBCU.2560x1440.jpg","C:\Temp\NBCU_Wallpaper\4K"),     #NBCU Defualt wallpaper 2560x1440
    @("http://eclapwp00556.tfayd.com/WVDFiles/WVD Help.url","C:\Users\Public\Desktop"),           #WVD Help page link to public desktop
    @("http://eclapwp00556.tfayd.com/WVDFiles/Internet Explorer.lnk","C:\Users\Public\Desktop"),  #IE11 Icon to public desktop
    @("http://eclapwp00556.tfayd.com/Apps/SCCM/SCCMClient.EXE","C:\Temp\"))                       #NBCU SCCM Client installer

        Try {
            foreach ($FileToDownload in $FilesToDownload) {
                
                $FILEVAL0 = $FileToDownload[0]
                $FILEVAL1 = $FileToDownload[1]
                Get-WebFiles -APPURL $FILEVAL0 -APPINSTALLPATH $FILEVAL1
            }
        }

        Catch{
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Could not copy the files: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        }



    ### Importing Power Config File ###
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Setting NBCU Power Settings"
    
    #Path
    $PowerSettingsPaths= "C:\temp\Build\" # NBCU Wallpaper path on local machine

        Try {
      
    
                Set-PowerSettings -POWERFILEPATH $PowerSettingsPaths
          
        }

        Catch{
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Could not set the Power Plan: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        }


    ### Configuring NBCU Wallpaper ###
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Setting NBCU Wallpaper"

    #Path
    $WallPaperPaths=@(
    @("C:\temp\NBCU_Wallpaper")) # NBCU Wallpaper path on local machine

        Try {
            foreach ($WallPaperPath in $WallPaperPaths) {
    
                Set-NBCUWallpaper -WPPATH $WallPaperPath
            }
        }

        Catch{
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Could not set the default wallpaper: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        }



    ### Configure Windows Services ###
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Beginning the configuration of Computer services."

    #Service / StartupType / RunState
    $WindowsServices=@(
    @("VaultSvc", "Disabled", "Stop"),            #Credential Manager
    @("TrkWks", "Disabled", "Stop"),              #Distributed Link Tracking Client
    @("RemoteRegistry", "Automatic", "Start"))    #Remote Registry

        Try {
            foreach ($WindowsService in $WindowsServices) {
    
                $SERVICENAMETOCHECK = $WindowsService[0]
                $SERVICESTARTUPTYPE = $WindowsService[1]
                $SERVICESTATE = $WindowsService[2]
                check-service $SERVICENAMETOCHECK $SERVICESTARTUPTYPE $SERVICESTATE   
            }
        }

        Catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Modifying the service failed: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        }



    ### Configuring Windows Roles and Features ###
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Beginning the configuration of Windows Roles and Features."

        #Action / Feature or Role Name
        $WindowsFeatures=@(
        @("Install", "Microsoft-Hyper-V"),       #HyperV
        @("Install", "NetFx4Extended-ASPNET45"), #ASP .Net4.8
        @("Install", "NetFx4-AdvSrvs"))          #.Net Framework 4.8 Advanced Services



        Try {
            foreach ($WindowsFeature in $WindowsFeatures) {
    
                $FEATUREACTION = $WindowsFeature[0]
                $FEATURENAME = $WindowsFeature[1]
                
                Set-RolesFeatures -Action $FEATUREACTION -FeatureRole $FEATURENAME
            }
        }

        Catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Adding the Role or Feature failed: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        }
        


    ### Network and Sharing Center / Advanced Sharing ###
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Beginning the configuration of Computer Network settings."

    #Disable Network Discovery (Private/Guest-Public/Domain) and Disable File and Print Sharing (Private/Guest Public)

    #FWService / StartupType / Profile
    $FWServices=@(
    @("Network Discovery", "False", "Any"),               #Network Discovery / Any
    @("File And Printer Sharing", "False", "Public"),     #File And Printer Sharing / Public
    @("File And Printer Sharing", "False", "Private"))    #File And Printer Sharing / Private

        Try {
            foreach ($FWService in $FWServices) {
    
                $FWSERVICENAMETOCHECK = $FWService[0]
                $FWSERVICESTARTUPTYPE = $FWService[1]
                $FWSERVICEPROFILE = $FWService[2]
                #Write-Log "Setting the $FWSERVICENAMETOCHECK session to $FWSERVICESTARTUPTYPE and $FWSERVICEPROFILE."
                    Set-FWRules $FWSERVICENAMETOCHECK $FWSERVICESTARTUPTYPE $FWSERVICEPROFILE  
            }
        }

        Catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Error: Could not set the configuration. Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        }



    ### Registry Configuration ###
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Beginning the configuration of Computer registry settings."

    #RegKey / Value / Key Type / Key Value Data
    $CompRegKeys=@(
    #@("HKLM:\SYSTEM\CurrentControlSet\Services\mpssvc", "Start", "DWord", "4"),                                      #Disable Windows Defender FW Service
    @("HKLM:\SYSTEM\CurrentControlSet\services\USBSTOR", "Start", "DWord", "4"),                                     #Block USB storage
    @("HKLM:\SYSTEM\CurrentControlSet\Control\Lsa", "RestrictAnonymous", "DWord", "1"),                              #Restrict Nul Session
    @("HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "CachedLogonsCount", "STRINGZ", "0"),           #Disable Cached Logon Creds
    @("HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters", "EnableSecuritySignature", "DWord", "1"),   #Enable SMB signing
    @("HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters", "RequireSecuritySignature", "DWord", "1"),  #Enable SMB Signing
    @("HKLM:\SOFTWARE\NBCU", "ImageVersion", "String", "$NBCImageTag"),                                                       #Image Tagging
    @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "LaunchTo", "DWord", "1"),                                  #File Explorer options - Open File Explorer to "This PC"
    @("HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl", "AutoReboot", "DWord", "0"),                                              #Advanced System Settings / Startup and Recovery - Disable Automatically Restart on System Failure
    @("HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance", "MaintenanceDisabled", "DWord", "0"),                 #Troubleshooting / Change Settings - Disable Computer Maintenance
    @("HKLM:\SYSTEM\Maps", "AutoUpdateEnabled", "DWord", "0"),                                                                         #Maps - Disable Map updates – automatically update maps
    @("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search", "AllowCortana", "DWord", "0"),                                       #Disable Corotona - GPO - Computer Configuration\Administrative Templates\Windows Components\Search\Allow Cortana
    @("HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings", "ActivePowerScheme", "STRING", "d586a4f4-b77c-4027-be9c-4eef8dd98ea4"), #PowerSettings - GPO - Computer Configuration\Administrative Templates\System\Power Management\Specify a custom active power plan
    @("HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\MitigationOptions", "MitigationOptions_FontBocking", "STRING", "3000000000000"))   #Enabled / Log Events without blocking untrusted fonts - GPO - Administrative Templates\System\Mitigation Options\Untrusted Font Blocking:  Enable/Block untrusted fonts and event


        Try {
            foreach ($CompRegKey in $CompRegKeys) {
    
                $CREGKEY = $CompRegKey[0]
                $CREGVAL = $CompRegKey[1]
                $CREGTYPE = $CompRegKey[2]
                $CREGDATA = $CompRegKey[3]
                Write-RegKey $CREGKEY $CREGVAL $CREGTYPE $CREGDATA
            }
        }

        Catch{ 
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Modifying the Registry failed: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        }




    ### Registry Import ###
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Beginning the configuration of Computer registry settings."

    #RegKey / Value / Key Type / Key Value Data
    $CompRegFiles=@(
    @("C:\Temp\Add_Personalization_to_Control_Panel.reg"),            #Reg File - Add Personalizations
    @("C:\Temp\Add_Classic_Personalization_to_Control_Panel.reg"))    #Reg File - Add Personalizations Classic


        Try {
            foreach ($CompRegFile in $CompRegFiles) {
    
                Import-RegFile $CompRegFile
            }
        }

        Catch{ 
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Modifying the Registry failed: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        }



    ### Remove Files in Path ###
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Beginning the cleanup of files."

    #File path
    $CompFiles=@(
    @("C:\Windows\System32\Macromed\Flash"),    #Flash Path
    @("C:\Windows\SysWOW64\Macromed\Flash"))    #SysWow64 Flash Path


        Try {
            foreach ($CompFile in $CompFiles) {
    
                Remove-Files -FPATH $CompFile
            }
        }

        Catch{ 
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Removing the files failed: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        }



    ### Remove Windows Apps ###
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Beginning the Removal of Windows Apps."

    $WindowsApps = @(

        #Unnecessary Windows 10 AppX Apps
        "Microsoft.3DBuilder"
        "Microsoft.AppConnector"
	    "Microsoft.BingFinance"
	    "Microsoft.BingNews"
	    "Microsoft.BingSports"
	    "Microsoft.BingTranslator"
	    "Microsoft.BingWeather"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.NetworkSpeedTest"
        "Microsoft.News"
        "Microsoft.Office.Lens"
        "Microsoft.Office.Sway"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.OneConnect"
        "Microsoft.People"
        "Microsoft.Print3D"
        "Microsoft.SkypeApp"
        "Microsoft.StorePurchaseApp"
        "Microsoft.Wallet"
        "Microsoft.Whiteboard"
        "Microsoft.WindowsAlarms"
        "microsoft.windowscommunicationsapps"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.WindowsMaps"
        "Microsoft.WindowsSoundRecorder"
        "Microsoft.ZuneMusic"
        "Microsoft.ZuneVideo"
        "Microsoft.MicrosoftStickyNotes"
        "Microsoft.MixedReality.Portal"
        "Microsoft.ScreenSketch"
        "Microsoft.Windows.Photos"
        "Microsoft.WindowsCamera"
        "Microsoft.Xbox.TCUI"
        "Microsoft.XboxApp"
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxGamingOverlay"
        "Microsoft.XboxIdentityProvider"
        "Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.YourPhone"
        "*EclipseManager*"
        "*ActiproSoftwareLLC*"
        "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
        "*Duolingo-LearnLanguagesforFree*"
        "*PandoraMediaInc*"
        "*CandyCrush*"
        "*BubbleWitch3Saga*"
        "*Wunderlist*"
        "*Flipboard*"
        "*Twitter*"
        "*Facebook*"
        "*Royal Revolt*"
        "*Sway*"
        "*Speed Test*"
        "*Dolby*"
        "*Viber*"
        "*ACGMediaPlayer*"
        "*Netflix*"
        "*OneCalendar*"
        "*LinkedInforWindows*"
        "*HiddenCityMysteryofShadows*"
        "*Hulu*"
        "*HiddenCity*"
        "*AdobePhotoshopExpress*"
        "*Microsoft.Advertising.Xaml_10.1712.5.0_x64__8wekyb3d8bbwe*"
        "*Microsoft.Advertising.Xaml_10.1712.5.0_x86__8wekyb3d8bbwe*"
        "*Microsoft.BingWeather*"
        "*Microsoft.WindowsStore*"
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
    }


    ### Adding Windows Capabilities that cannot be done via roles and features ###
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Beginning the installation of Windows Capabilities."

    ##File path 
    $CapItems=@(
    @("Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"),  #RSAT: DS-LDS Tools
    @("Rsat.FileServices.Tools~~~~0.0.1.0"),            #RSAT: File Services Tools
    @("Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0"),  #RSAT: Group Policy Management Tool
    @("Rsat.LLDP.Tools~~~~0.0.1.0"),                    #RSAT: LLDP Tools
    @("Rsat.DHCP.Tools~~~~0.0.1.0"),                    #RSAT: DHCP Tools
    @("Rsat.CertificateServices.Tools~~~~0.0.1.0"),     #RSAT: Certificate Services Tools
    @("Rsat.RemoteAccess.Management.Tools~~~~0.0.1.0"), #RSAT: Remote Access Tools
    @("Rsat.RemoteDesktop.Services.Tools~~~~0.0.1.0"),  #RSAT: Remote Desktop Services Tools
    @("Rsat.ServerManager.Tools~~~~0.0.1.0"),           #RSAT: Server Manager Tools
    @("NetFx3~~~~"))                                    #Net FrameWork 3.5

    
        Try {
            foreach ($CapItem in $CapItems) {
    
                Set-WindowsCapability -CapName "$CapItem"
            }
        }

        Catch{ 
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Adding Windows Capability failed: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        }


    ### Adding Windows Features via DISM ###
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Beginning the installation of Windows Features."

    #Features
    $FeatItems=@(
    @("TelnetClient"),  #Telnet Client
    @("NetFx3"))        #Net FrameWork 3.5

    
        Try {
            foreach ($FeatItem in $FeatItems) {
    
                dism /online /Enable-Feature /FeatureName:$FeatItem /NoRestart
            }
        }

        Catch{ 
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Adding Windows Feature failed: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        }


    ### Enable PSRemoting ###
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Enabling PSRemoting settings"

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


    ### Install PS Modules ###
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Installing PowerShell Modules"

    ##Modules 
    $ModNames=@(
    @("Az"),               #Azure Module
    @("PSWindowsUpdate"))  #Windows Updates


        Try {
            Install-PackageProvider -Name NuGet -Force
            foreach ($ModName in $ModNames) {
    
                Install-Module -Name $ModName -Force -Scope AllUsers -AllowClobber
            }
        }

        Catch{ 
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Failed to install modules $ModNames : $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        }



}else{

    Write-Log "Skipping Computer Based Configuration."

}


if ($USERSETTINGS -eq "true") {

        ### User Settings ###
        Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
        Write-Log "Beginning the configuration of User registry settings."

        #Mount NTUser.Dat
            Write-Output "Mounting C:\Users\Default\NTUser.dat to HKLM:\Default to modify default User registry settings."
                $REGMOUNTED = test-path HKLM:\Default
                if (!($REGMOUNTED)) {
                    & REG LOAD HKLM\DEFAULT C:\Users\Default\NTUSER.DAT
                    if ((test-path HKLM:Default)){Write-output "Successfully mounted C:\Users\Default\NTUser.dat to HKLM:\Default"}else{Write-Log "Error: Could not mount NTUser.dat."}

                }else{

                write-log "Warning: HKLM:\Default is already mounted. or cannot be varified.  This is unexpected behavior and the user reg keys will not be set."

                }



    ### Removing User Based Reg Keys ###

    #RegKey / Value
    $UserNoRegKeys=@(
    @("HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Ribbon", "QatItems"),
    @("HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Ribbon", "QatItems0"))  # File Explorer options - #Disable Quick Access Defaults (Desktop/Documents/Downloads/Pictures)

        Try {
            foreach ($UserNoRegKey in $UserNoRegKeys) {
    
                $UNREGKEY = $UserNoRegKey[0]
                $UNREGVAL = $UserNoRegKey[1]
                Remove-RegKey $UNREGKEY $UNREGVAL
            }
        }

        Catch{
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Removing the Registry Key failed: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        }



    #RegKey / Value / Key Type / Key Value Data
    $UserRegKeys=@(
    @("HKLM:\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers", "DisableAutoPlay", "DWord", "1"),            #File Explorer options - Disbale Autoplay
    @("HKLM:\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "DisallowRun", "DWord", "1"),                        #Disallow Run - Enabled
    @("HKLM:\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Policies\DisallowRun", "1", "DWord", "pangpa.exe"),             #Disallow Run - 1 - pangpa.exe
    @("HKLM:\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Policies\DisallowRun", "2", "DWord", "openvpn.exe"),            #Disallow Run - 2 - openvpn.exe
    @("HKLM:\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Policies\DisallowRun", "3", "DWord", "openvpn-gui.exe"),        #Disallow Run - 3 - openvpn-gui.exe
    @("HKLM:\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer", "ShowRecent", "DWord", "0"),                                  #File Explorer options - Disbale Show recently used files in Quick Access
    @("HKLM:\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer", "ShowFrequent", "DWord", "0"),                                #File Explorer options - Disable Show recently used folders in Quick Access     
    @("HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "AlwaysShowMenus", "DWord", "0"),                    #File Explorer options - Enable Always show menus
    @("HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState", "FullPath", "DWord", "1"),                       #File Explorer options - Enable Show Full path in the Title bar
    @("HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "HideDrivesWithNoMedia", "DWord", "1"),              #File Explorer options - Disable Hide Empty Drives
    @("HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "HideFileExt", "DWord", "0"),                        #File Explorer options - Disable Hide extentions for known file types
    @("HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "HideMergeConflicts", "DWord", "0"),                 #File Explorer options - Disable Hide Folder Merge Conflicts
    @("HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "SeparateProcess", "DWord", "1"),                    #File Explorer options - Enable Launch Folder Windows in a Separate Process
    @("HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "PersistBrowsers", "DWord", "1"),                    #File Explorer options - Enable Restore Previous Folder Windows at Logon
    @("HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "ShowEncryptCompressedColor", "DWord", "1"),         #File Explorer options - Enable Show encrypted or compressed NTFS files in color
    @("HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "SharingWizardOn", "DWord", "0"),                    #File Explorer options - Disable Use Sharing Wizard
    @("HKLM:\Default\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications", "NoToastApplicationNotificationOnLockScreen", "DWord", "1"),         #Notification and Actions - Disable Show notifications on the lock screen - GPO - Start Menu and Taskbar\Notifications\Turn off toast notifications on the lock screen
    @("HKLM:\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings", "NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK", "DWord", "0"),    #Notification and Actions - #Disable Show reminders and incoming VOIP calls on the lock screen
    @("HKLM:\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SubscribedContent-338389Enabled", "DWord", "0"),                        #Notification and Actions - #Disable Get tips, tricks, and suggestions as you use Windows - #GPO - Computer Configuration\Administrative Templates\Windows Components\Cloud Content\Do not show Windows tips
    @("HKLM:\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SubscribedContent-310093Enabled", "DWord", "0"),                        #Notification and Actions - Disable Show me the Windows welcome experience screen after updates and occasionally when I sign in to highlight what’s new and suggested,
    @("HKLM:\Default\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows", "LegacyDefaultPrinterMode", "DWord", "1"),    #Printers & Scanners - Disable Let Windows manage my default printer
    @("HKLM:\Default\Software\Microsoft\Input\Settings", "EnableHwkbAutocorrection", "DWord", "1"),                  #Typing - Autocorrect misspelled words I type (Hardware Keyboard)
    @("HKLM:\Default\Software\Microsoft\Input\Settings", "EnableHwkbTextPrediction", "DWord", "1"),                  #Typing - Enable Show text suggestions as I type (Hardware Keyboard)
    @("HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo", "Enabled", "DWord", "0"),             #Privacy - #Disbale Let apps use my advertising ID to make ads more interesting to you based on your app usage - #GPO - Computer Configuration\Administrative Templates\System\User Profile\Turn off the advertising ID
    @("HKLM:\Default\Control Panel\International\User Profile", "HttpAcceptLanguageOptOut", "DWord", "1"),             #Privacy - Disable Let websites provide locally relevant content by accessing my language list
    @("HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.ZuneMusic_8wekyb3d8bbwe", "Disabled", "DWord", "1"),                     #Background Apps - Disable Groove
    @("HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.ZuneMusic_8wekyb3d8bbwe", "IgnoreBatterySaver", "DWord", "0"),           #Background Apps - Disable Groove
    @("HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.XboxGameCallableUI_cw5n1h2txyewy", "Disabled", "DWord", "1"),            #Background Apps - Disable XBOX
    @("HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.XboxGameCallableUI_cw5n1h2txyewy", "IgnoreBatterySaver", "DWord", "0"),  #Background Apps - Disable XBOX
    @("HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.People_8wekyb3d8bbwe", "Disabled", "DWord", "1"),                        #Background Apps - Disable People
    @("HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.People_8wekyb3d8bbwe", "IgnoreBatterySaver", "DWord", "0"),              #Background Apps - Disable People
    @("HKLM:\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel", "{20D04FE0-3AEA-1069-A2D8-08002B30309D}", "DWord", "0"),       #Desktop Icon Settings - Enable Computer
    @("HKLM:\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SubscribedContent-338388Enabled", "DWord", "0"),          #Start Bar - Disable Show Suggestions occasionally in start
    @("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer", "NoRemoteDestinations", "DWord", "1"),                                                 #Start Bar - Disable Show recently opened items in jump lists on start or the taskbar - GPO - User Configuration\Administrative Templates\Start Menu and Taskbar\Do not display or track items in Jump Lists from remote locations
    @("HKLM:\Default\SOFTWARE\Policies\Microsoft\Windows\Explorer", "NoRemoteDestinations", "DWord", "1"))                                         #Start Bar - Disable Show recently opened items in jump lists on start or the taskbar - GPO - User Configuration\Administrative Templates\Start Menu and Taskbar\Do not display or track items in Jump Lists from remote locations


        Try {
            foreach ($UserRegKey in $UserRegKeys) {
    
                $UREGKEY = $UserRegKey[0]
                $UREGVAL = $UserRegKey[1]
                $UREGTYPE = $UserRegKey[2]
                $UREGDATA = $UserRegKey[3]
                Write-RegKey $UREGKEY $UREGVAL $UREGTYPE $UREGDATA
            }
        }

        Catch{ 
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Modifying the Registry failed: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        }



    #Unmounting NTUser.DAT from Registry
        Write-Output "Unmounting NTUser.Dat"
            $unloaded = $false
            $attempts = 0
            while (!$unloaded -and ($attempts -le 5)) {
                [gc]::Collect() # necessary call to be able to unload registry hive
                & REG UNLOAD HKLM\DEFAULT
                $unloaded = $?
                $attempts += 1
            }
            if (!$unloaded) {
                Write-Log "Unable to dismount default user registry hive at HKLM\DEFAULT - manual dismount required"
            }

}else{

    Write-Log "Skipping User Based Configuration."

}



if ($APPLICATIONS -eq "true") {

    ### Download Core Applications ###
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Beginning the download of core applications."

    #Download Path / Install Dir
    $AppDetails=@(
    @("http://eclapwp00556.tfayd.com/Apps/Java/JavaRE.EXE","C:\install\Java\"),                                                                        #Java
    @("http://eclapwp00556.tfayd.com/Apps/365/setup.exe","C:\install\365\"),                                                                           #o365
    @("http://eclapwp00556.tfayd.com/Apps/365/ConfigWVD-64.xml","C:\install\365\"),                                                                    #o365 config
    @("http://eclapwp00556.tfayd.com/Apps/365/Office/Data/v64_16.0.14326.20852.cab","C:\install\365\office\data\"),                                    #o365 cab
    @("http://eclapwp00556.tfayd.com/Apps/365/Office/Data/16.0.14326.20852/i640.cab","C:\install\365\office\data\16.0.14326.20852\"),                  #o365 cab
    @("http://eclapwp00556.tfayd.com/Apps/365/Office/Data/16.0.14326.20852/i640.cab.cat","C:\install\365\office\data\16.0.14326.20852\"),              #o365 cat
    @("http://eclapwp00556.tfayd.com/Apps/365/Office/Data/16.0.14326.20852/i641033.cab","C:\install\365\office\data\16.0.14326.20852\"),               #o365 cab
    @("http://eclapwp00556.tfayd.com/Apps/365/Office/Data/16.0.14326.20852/s640.cab","C:\install\365\office\data\16.0.14326.20852\"),                  #o365 cab
    @("http://eclapwp00556.tfayd.com/Apps/365/Office/Data/16.0.14326.20852/s641033.cab","C:\install\365\office\data\16.0.14326.20852\"),               #o365 cab
    @("http://eclapwp00556.tfayd.com/Apps/365/Office/Data/16.0.14326.20852/stream.x64.en-us.dat","C:\install\365\office\data\16.0.14326.20852\"),      #o365 dat
    @("http://eclapwp00556.tfayd.com/Apps/365/Office/Data/16.0.14326.20852/stream.x64.en-us.dat.cat","C:\install\365\office\data\16.0.14326.20852\"),  #o365 cat
    @("http://eclapwp00556.tfayd.com/Apps/365/Office/Data/16.0.14326.20852/stream.x64.x-none.dat","C:\install\365\office\data\16.0.14326.20852\"),     #o365 dat
    @("http://eclapwp00556.tfayd.com/Apps/365/Office/Data/16.0.14326.20852/stream.x64.x-none.dat.cat","C:\install\365\office\data\16.0.14326.20852\"), #o365 cat
    @("http://eclapwp00556.tfayd.com/Apps/PowerBI/PowerBI.EXE","C:\install\PowerBI\"),                      #PowerBIDesktop    
    @("http://eclapwp00556.tfayd.com/Apps/OneDrive/OneDriveSetup.exe","C:\install\OneDrive\"),              #OneDrive
    @("http://eclapwp00556.tfayd.com/Apps/Qualys/QualysCloudAgent.exe","C:\Qualys\"),                       #Qualys
    @("http://eclapwp00556.tfayd.com/Apps/iNews/iNews.EXE","C:\Install\iNews\"),                            #iNews
    @("http://eclapwp00556.tfayd.com/Apps/Dali/DALi.EXE","C:\Install\DALi\"),                               #Dali iNews Plugin
    @("http://eclapwp00556.tfayd.com/Apps/ELC/ELC.EXE","C:\Install\ELC\"),                                  #ELC iNews Plugin    
    @("http://eclapwp00556.tfayd.com/Apps/XPM/XPM.EXE","C:\Install\XPM\"),                                  #XPM iNews Plugin
    @("http://eclapwp00556.tfayd.com/Apps/VizPilot/VizPilot.EXE","C:\Install\VizPilot\"),                   #VizPilot iNews Plugin
    @("http://eclapwp00556.tfayd.com/Apps/SAP/SAPGUI.EXE","C:\Install\SAP\SAPGUI\"),                        #SAPGUI       
    @("http://eclapwp00556.tfayd.com/Apps/SAP/SAP_AOE.EXE","C:\Install\SAP\AfO\"),                          #SAP-AfO    
    @("http://eclapwp00556.tfayd.com/Apps/SAP/SAP_ClientEncryption.EXE","C:\Install\SAP\CE\"),              #SAP-CE    
    @("http://eclapwp00556.tfayd.com/Apps/SAP/SAP_XMLConfig.EXE","C:\Install\SAP\XML\"),                    #SAP-XML    
    @("http://eclapwp00556.tfayd.com/Apps/7zip/7-Zip.EXE","C:\Install\7Zip\"),                              #7zip
    @("http://eclapwp00556.tfayd.com/Apps/SMSS/SQLServerManagementStudio.EXE","C:\Install\SSMS\"),          #SSMS
    @("http://eclapwp00556.tfayd.com/Apps/VisioViewer/visioviewer.exe","C:\Install\VisioViewer\"),          #VisioViewer
    @("http://eclapwp00556.tfayd.com/Apps/VNCViewer/VNC-Viewer.msi","C:\Install\VNCViewer\"),               #VNCViewer
    @("http://eclapwp00556.tfayd.com/Apps/Edge/MicrosoftEdgeEnterpriseX64.msi","C:\Install\Edge\"),         #MS Edge
    @("http://eclapwp00556.tfayd.com/Apps/Teams_WVD/VC_redist.x64.exe","C:\Install\1Teams\"),               #VC++ 2015/2017/2019
    @("http://eclapwp00556.tfayd.com/Apps/Teams_WVD/MsRdcWebRTCSvc_HostSetup.msi","C:\Install\2Teams\"),    #MsRdcWebRTCSvc HostSetup
    @("http://eclapwp00556.tfayd.com/Apps/Teams_WVD/Teams_windows_x64.msi","C:\Install\3Teams\"),           #Teams Installer
    @("http://eclapwp00556.tfayd.com/Apps/FSLogix_WVD/FSLogixAppsSetup.exe","C:\Install\1FSLogix"),         #FSLogix App Setup    
    @("http://eclapwp00556.tfayd.com/Apps/ReaderDC/AdobeReaderDC.EXE", "C:\install\ReaderDC\"),             #Adobe Reader DC
    @("http://eclapwp00556.tfayd.com/Apps/Firefox/FireFox.msi", "C:\install\Firefox\"),                     #Mozilla Firefox
    @("http://eclapwp00556.tfayd.com/Apps/Chrome/ChromeEnterprise.EXE", "C:\install\Chrome\"),              #Chrome Enterprise
    @("http://eclapwp00556.tfayd.com/Apps/HDTools/NBCUHelpdeskTools.EXE", "C:\install\HDTools\"),           #HelpDesk Tools
    @("http://eclapwp00556.tfayd.com/Apps/ROCKFonts/RockFonts.exe", "C:\install\ROCKFonts\"),               #ROCK Fonts
    @("http://eclapwp00556.tfayd.com/Apps/SymFonts/symphony.exe", "C:\install\SymFonts\"),                  #Symphony Fonts
    @("http://eclapwp00556.tfayd.com/Apps/CrowdStrike/CrowdStrike.EXE", "C:\install\Crowdstrike\"),         #Crowdstrike
    @("http://eclapwp00556.tfayd.com/Apps/AppVentiX/AppVentiXAgent.msi", "C:\install\AppVentiX\"),          #AppVentiXAgent
    @("http://eclapwp00556.tfayd.com/Apps/AppVentiX/AppVentiX.reg", "C:\temp\build\"),                      #AppVentiXAgentReg
    @("http://eclapwp00556.tfayd.com/Apps/iAccess/IBM_iAccessClient.EXE", "C:\install\iAccess"),            #IBM iAccess
    @("http://eclapwp00556.tfayd.com/Apps/Promenta/Promenta.EXE", "C:\install\Promenta"),                   #Promenta Excel Add-In
    @("http://eclapwp00556.tfayd.com/Apps/SecurePrint/SecurePrint.EXE", "C:\install\SecurePrint"),          #SecurePrint
    @("http://eclapwp00556.tfayd.com/Apps/Workspaces/CitrixWorkspaceClient.EXE", "C:\install\Workspaces\")) #Citrix Workspaces


        Try {
            foreach ($AppDetail in $AppDetails) {

                $APPDL00 = $AppDetail[0]
                $APPDL01 = $AppDetail[1]

                Get-WebFiles -APPURL $APPDL00 -APPINSTALLPATH $APPDL01

            }
        }Catch{
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Error: Could not install software: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        }



    ### Install Core Applications ###


    #This section will install all NBCU EXE files in any recursive folder in the Install directory.
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Beginning the installation of core applications."

    $APPVENTIXPATH = "\\wvdazuresteast.file.core.windows.net\appventix"

    #Install Path / Seconds to Wait / Install Parameters
    $AppInstallDetails=@(
    @("C:\install\OSOP\","90", "-t C:\install\OSOP\Template.xml -applyoptimization C:\install\OSOP\Selection.json -v -o"),        #VMWare OS Optimization Tool
    @("C:\install\SSMS\","600", "/D /-R /NOCLOCK /AS"),             #SSMS
    @("C:\install\VisioViewer\","120", "/quiet /norestart"),        #VisioViewer
    @("C:\install\VNCViewer\","120", "/qn ALLUSER=1"),              #VNCViewer
    @("C:\install\ReaderDC\","120", "/D /-R /NOCLOCK /AS"),         #Adobe Reader DC
    @("C:\install\PowerBI\","120", "/D /-R /NOCLOCK /AS"),          #PowerBI Desktop
    @("C:\install\Edge\","120", "/qn ALLUSER=1"),                   #MS Edge
    @("C:\install\Firefox\","120", "/qn ALLUSER=1"),                #Mozilla Firefox
    @("C:\install\Workspaces\","120", "/D /AS"),                    #Citrix Workspaces   
    @("C:\install\Chrome\","120", "/D /-R /AS"),                    #Chrome Enterprise
    @("C:\install\HDTools\","30", "/D /-R /AS"),                    #HelpDesk Tools
    @("C:\install\ROCKFonts\","30", "/D /-R /AS"),                  #ROCK Fonts
    @("C:\install\SymFonts\","30", "/D /-R /NOCLOCK /AS"),          #Symphony Fonts
    @("C:\install\Crowdstrike\","90", "/D /-R /AS"),                #Crowdstrike
    @("C:\Install\1Teams\","30","-install -quiet -norestart"),      #VC++ 2015/2017/2019
    @("C:\Install\2Teams\","30","/qn ALLUSER=1"),                   #MsRdcWebRTCSvc HostSetup
    @("C:\install\365\","600", "/configure C:\install\365\ConfigWVD-64.xml"),      #o365
    @("C:\Install\3Teams\","60","/qn ALLUSER=1"),                   #Teams Installer   
    @("C:\install\OneDrive\","60", "/silent /allusers"),            #OneDrive
    @("C:\install\iAccess\","60", "/D /-R /NOCLOCK /AS"),           #iAccess
    @("C:\install\Promenta\","60", "/D /-R /NOCLOCK /AS"),          #Promenta
    @("C:\install\SecurePrint\","60", "/D /-R /NOCLOCK /AS"),       #SecurePrint
    @("C:\Install\iNews\","60","/D /-R /AS"),                       #iNews
    @("C:\Install\VizPilot\","60","/D /-R /AS"),                    #VizPilot
    @("C:\Install\XPM\","60","/D:N /-R /AS"),                       #XPM
    @("C:\Install\DALi\","60","/D /-R /G:NE /NOSHLCHK /AS"),        #DALi
    @("C:\Install\SAP\SAPGUI\","600","/D:N /-R /NOCLOCK /AS"),      #SAPGUI
    @("C:\Install\SAP\AfO\","60","/D /-R /NOCLOCK /AS"),            #SAP-AfO
    @("C:\Install\SAP\CE\","60","/D /-R /NOCLOCK /AS"),             #SAP-CE
    @("C:\Install\SAP\XML\","60","/D /-R /NOCLOCK /AS"),            #SAP-XML
    @("C:\Install\7zip\","60","/D /-R /AS"),                        #7zip
    @("C:\Install\Java\","60","/D /-R /AS"),                        #Java
    @("C:\Install\1FSLogix","60","/install /quiet /norestart"),     #FSLogix App Setup  
    @("C:\Install\AppVentiX","30","/quiet CONFIGURATIONSHARE=$APPVENTIXPATH"))  #AppVentiXAgent




    foreach ($AppInstallDetail in $AppInstallDetails) {

        $X = $AppInstallDetail[0]
        $Y = $AppInstallDetail[1]
        $Z = $AppInstallDetail[2]


        Try {

            Install-CoreApps -APPINSTALLPATH $X -SECONDSTOWAIT $Y -APPPARAM $Z
            start-sleep -Seconds $Y

        }Catch{
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Error: Could not install the applications. Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        }
    
    
    }



    ### Application Registry Configuration ###
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Beginning the configuration of Application specific registry settings."

    #RegKey / Value / Key Type / Key Value Data
    $AppRegKeys=@(
    @("HKLM:\SOFTWARE\Microsoft\Teams", "IsWVDEnvironment", "DWord", "1"),                                         #Enable media optimization for Teams !!!Move to section post software install!!!
    @("HKLM:\SOFTWARE\Policies\Google\Chrome", "AudioSandboxEnabled", "DWord", "0"),                               #Enable Audio in Chrome
    @("HKLM:\SOFTWARE\Policies\Microsoft\Edge", "AudioSandboxEnabled", "DWord", "0"),                              #Enable Audio in Edge
    @("HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge", "AudioSandboxEnabled", "DWord", "0"))                     #Enable Audio in Edge

        Try {
            foreach ($AppRegKey in $AppRegKeys) {
    
                $AREGKEY = $AppRegKey[0]
                $AREGVAL = $AppRegKey[1]
                $AREGTYPE = $AppRegKey[2]
                $AREGDATA = $AppRegKey[3]
                Write-RegKey $AREGKEY $AREGVAL $AREGTYPE $AREGDATA
            }
        }

        Catch{ 
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Modifying the Registry failed: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        }


    ### Application Registry Import ###
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Beginning the configuration of Application registry settings."

    #RegKey / Value / Key Type / Key Value Data
    $AppRegFiles=@(
    @("C:\temp\build\AppVentiX.reg"),         #Reg File - AppVentiX Service Account
    @("C:\temp\build\o365SharedKey.reg"))            #Reg File - o365 Shared Key


        Try {
            foreach ($AppRegFile in $AppRegFiles) {
    
                Import-RegFile "$AppRegFile"
            }
        }

        Catch{ 
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Modifying the Registry failed: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        }


    ### Application File Modification ###
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Beginning the configuration of post application Service settings."

    #Old file name / New file name
    $FileDetails=@(
    @("C:\Program Files (x86)\Google\Update\GoogleUpdate.exe", "C:\Program Files (x86)\Google\Update\GoogleUpdate_stop.exe"),                               #Stop Google Update
    @("C:\Program Files (x86)\Microsoft\EdgeUpdate\MicrosoftEdgeUpdate.exe", "C:\Program Files (x86)\Microsoft\EdgeUpdate\MicrosoftEdgeUpdate_stop.exe"))   #Stop Edge Update


        Try {
            foreach ($FileDetail in $FileDetails) {
                $FDeatil0 = $FileDeatil[0]
                $FDeatil1 = $FileDeatil[1]


                Rename-Files -FILESOURCEPATH $FDeatil0 -FILEDESTPATH $FDeatil1
    
            }  
            
        }

        Catch{ 
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Renaming the files failed: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        }




    ### Configure Application Services ###
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Beginning the configuration of Application services."

    #Service / StartupType / RunState
    $WindowsServices=@(
    @("AdobeARMservice", "Disabled", "Stop"),       #Adobe UpdaterMozillaMaintenance
    @("MozillaMaintenance", "Disabled", "Stop"),    #Firefox Updater
    @("CWAUpdaterService", "Disabled", "Stop"),     #Citrix Updater
    @("gupdate", "Disable", "Stop"))                #Chrome Updater

        Try {
            foreach ($WindowsService in $WindowsServices) {
    
                $SERVICENAMETOCHECK = $WindowsService[0]
                $SERVICESTARTUPTYPE = $WindowsService[1]
                $SERVICESTATE = $WindowsService[2]
                check-service $SERVICENAMETOCHECK $SERVICESTARTUPTYPE $SERVICESTATE   
            }
        }

        Catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Modifying the service failed: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        }



    ### Configure Application Scheduled Tasks ###
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Beginning the configuration of Application Scheduled Tasks."

    #Task Name / StartupType
    $WindowsTasks=@(
    @("Adobe Acrobat Update Task", "Disabled"),      #Adobe Acrobat Update Task
    @("GoogleUpdateTaskMachineCore", "Disabled"),    #GoogleUpdateTaskMachineCore
    @("GoogleUpdateTaskMachineUA", "Disable"))       #GoogleUpdateTaskMachineUA

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
            Write-Log "Modifying the tasks failed: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        }





    ### Add Local Group Membership for Applications ###
    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-Log "Beginning the configuration of post application account settings."

    #User / UserSID / Service / AccountPW
    $LocalGroups=@(
    @("FSLogix Profile Exclude List", "WVDAdmin"),   #Add WVDAdmin to FSLogix Profile Exclusion group
    @("FSLogix ODFC Exclude List", "WVDAdmin"))      #Add WVDAdmin to FSLogix Profile Exclusion group

    foreach ($LocalGroup in $LocalGroups) {

        $LG00 = $LocalGroup[0]
        $LG01 = $LocalGroup[1]
        Add-LocalGroupMember -Group $LG00 -Member $LG01
    }



 }else{

    Write-Log "Skipping Application installation."

 }



    ### Cleanup ###
if ($CLEANUP -eq "true") { 
    Try {
        Write-Log "Removing setup directories and all sub directories."
        if ((test-path "C:\Install")) {Remove-Item -path "C:\Install" -Recurse -Force}
        Get-ChildItem C:\Users\Public\Desktop\ | Remove-Item
        #if ((test-path "C:\Temp")) {Remove-Item -path "C:\Temp" -Recurse -Force}

    }Catch{
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        $FullMessage = $Error[0].Exception.GetType().FullName
        Write-Log "Error: Could not remove one or more of the install directories. Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
    }
        

    ### Get Desktop Icons and SCCM Client ###

    #Source Path and File / Destination Path
    $DTFilesToDownload=@(
    @("http://eclapwp00556.tfayd.com/WVDFiles/WVD Help.url","C:\Users\Public\Desktop"),           #WVD Help page link to public desktop
    @("http://eclapwp00556.tfayd.com/WVDFiles/Internet Explorer.lnk","C:\Users\Public\Desktop"),  #IE11 Icon to public desktop
    @("http://eclapwp00556.tfayd.com/Apps/SCCM/SCCMClient.EXE","C:\Temp\SCCM\"))                  #NBCU SCCM Client installer

        Try {
            foreach ($DTFileToDownload in $DTFilesToDownload) {
                
                $DTFILEVAL0 = $DTFileToDownload[0]
                $DTFILEVAL1 = $DTFileToDownload[1]
                Get-WebFiles -APPURL $DTFILEVAL0 -APPINSTALLPATH $DTFILEVAL1
            }
        }

        Catch{
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $FullMessage = $Error[0].Exception.GetType().FullName
            Write-Log "Could not copy the files: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
        }


    ### Install SCCM Agent ###

    Install-CoreApps -APPINSTALLPATH "C:\temp\SCCM\" -SECONDSTOWAIT "240" -APPPARAM "/D /-R /AS"
    Start-Sleep 60
    do {Out-Null} while (get-process -Name ccmsetup)
    Get-Service -Name CcmExec | Stop-Service
    Remove-Item -Path C:\windows\SMSCFG.ini -Force
    Remove-Item -Path HKLM:\Software\Microsoft\SystemCertificates\SMS\Certificates\* -Force
    wmic /namespace:\root\ccm\invagt path inventoryActionStatus where InventoryActionID=”{00000000-0000-0000-0000-000000000001}” DELETE /NOINTERACTIVE


    ### Create Schedule Task for Run Once Script ###
    $taskAction = New-ScheduledTaskAction `
        -Execute 'powershell.exe' `
        -Argument '-NoProfile -executionpolicy bypass -File "C:\runonce\WVDRunOnce_v3.ps1"'

    $taskTrigger = New-ScheduledTaskTrigger -AtStartup

    $taskSettings = new-scheduledtasksettingsset -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

    # The name of your scheduled task.
    $taskName = "WVDSetup"


    # Register the scheduled task

    Register-ScheduledTask `
        -TaskName $taskName `
        -Action $taskAction `
        -Trigger $taskTrigger `
        -Settings $taskSettings `
        -User "NT AUTHORITY\SYSTEM" 

    Disable-ScheduledTask -TaskName "WVDSetup"


    Write-Log "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    write-log "Complete configuration of device: $env:COMPUTERNAME."
    Write-Output "Finished configuring: $($env:COMPUTERNAME)."
    Write-Output "You can find the log at $FULLLOGPATH"
}