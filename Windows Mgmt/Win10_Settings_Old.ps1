#PowerShell Registry Reference - 
#https://msdn.microsoft.com/en-us/powershell/scripting/getting-started/cookbooks/working-with-registry-entries?f=255&MSPPError=-2147217396


#Create registry path if it doesn't exist. Then modify entry value. 
 Function WriteRegKey{
 
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
        New-ItemProperty -Path $registryPath -Name $regName -PropertyType $regType -Value $regValue -Force | Write-Host
    #}
    
    #Catch{AppendLog "$((Get-PSCallStack)[1].Command) Set Registry Value failed: $LASTEXITCODE; Error Details: $($_.ErrorDetails); Error Stack Trace: $($_.ScriptStackTrace); Target Object: $($_.TargetObject); Invocation Info: $($_.InvocationInfo)"}

}

#Remove registry item if it exists
 Function RemoveRegKey{
 
    Param(
        [Parameter(Mandatory=$true)]
        [string]$registryPath,
        [Parameter(Mandatory=$true)]
        [string]$regName
    )
    
    #Try{
        If((Test-Path $registryPath$regName)){
            Remove-ItemProperty -Path $registryPath -Name $regName -Force | Write-Host
        }
    #}
    
    #Catch{AppendLog "$((Get-PSCallStack)[1].Command) Delete Registry Value failed: $LASTEXITCODE; Error Details: $($_.ErrorDetails); Error Stack Trace: $($_.ScriptStackTrace); Target Object: $($_.TargetObject); Invocation Info: $($_.InvocationInfo)"}
}

#####Added or modified registry entries


#Set File Explorer to Launch to ThisPC
WriteRegKey "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" "DWord" "1"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Windows Update - Configure Automatic Updates - Disabled
WriteRegKey "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoUpdate" "DWord" "1"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Windows Media Player - Prevent Quick Launch Toolbar Shortcut Creation - Enabled
WriteRegKey "HKLM:\Software\Policies\Microsoft\WindowsMediaPlayer" "QuickLaunchShortcut" "String" "no"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Windows Media Player - Prevent Media Sharing - Enabled
WriteRegKey "HKLM:\Software\Policies\Microsoft\WindowsMediaPlayer" "PreventLibrarySharing" "DWord" "1"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Windows Media Player - Prevent Desktop Shortcut Creation - Enabled
WriteRegKey "HKLM:\Software\Policies\Microsoft\WindowsMediaPlayer" "DesktopShortcut" "String" "no"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Windows Media Player - Prevent Automatic Updates - Enabled
WriteRegKey "HKLM:\Software\Policies\Microsoft\WindowsMediaPlayer" "DisableAutoUpdate" "DWord" "1"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Windows Media Player - Do Not Show First Use Dialog Boxes - Enabled
WriteRegKey "HKLM:\Software\Policies\Microsoft\WindowsMediaPlayer" "GroupPrivacyAcceptance" "DWord" "1"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Windows Ink Workspace - Allow suggested apps in Windows Ink Workspace - Disabled
WriteRegKey "HKLM:\Software\Policies\Microsoft\WindowsInkWorkspace" "AllowSuggestedAppsInWindowsInkWorkspace" "DWord" "0"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Windows Defender - Turn off Windows Defender - Enabled
WriteRegKey "HKLM:\Software\Policies\Microsoft\Windows Defender" "DisableAntiSpyware" "DWord" "1"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Sync your settings - Do not sync - Enabled
WriteRegKey "HKLM:\Software\Policies\Microsoft\Windows\SettingSync" "DisableSettingSync" "DWord" "2"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Sync your settings - Allow users to turn syncing on - Disabled
#WriteRegKey "HKLM:\Software\Policies\Microsoft\Windows\SettingSync" "DisableSettingSyncUserOverride" "DWord" "1"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Store - Turn off the Store application - Enabled
WriteRegKey "HKLM:\Software\Policies\Microsoft\WindowsStore" "RemoveWindowsStore" "DWord" "1"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Store - Turn off the offer to update to the latest version of Windows - Enabled
WriteRegKey "HKLM:\Software\Policies\Microsoft\WindowsStore" "DisableOSUpgrade" "DWord" "1"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Store - Turn off Automatic Download and Install of updates - Enabled
WriteRegKey "HKLM:\Software\Policies\Microsoft\WindowsStore" "AutoDownload" "DWord" "2"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Search - Prevent automatically adding shared folders to the Windows Search index - Enabled
WriteRegKey "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AutoIndexSharedFolders" "DWord" "1"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Search - Do not allow locations on removable drives to be added to libraries - Enabled
WriteRegKey "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "DisableRemovableDriveIndexing" "DWord" "1"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Search - Allow search and Cortana to use location - Disabled
WriteRegKey "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowSearchToUseLocation" "DWord" "0"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Search - Allow Cortana above lock screen - Disabled
WriteRegKey "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCortanaAboveLock" "DWord" "0"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Search - Allow Cortana - Disabled
WriteRegKey "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCortana" "DWord" "0"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Online Assistance - Turn off Active Help - Enabled
WriteRegKey "HKLM:\Software\Policies\Microsoft\Assistance\Client\1.0" "NoActiveHelp" "DWord" "1"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Maps - Turn off unsolicited network traffic on the Offline Maps settings page - Enabled
WriteRegKey "HKLM:\Software\Policies\Microsoft\Windows\Maps" "AllowUntriggeredNetworkTrafficOnSettingsPage" "DWord" "0"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Maps - Turn off Automatic Download and Update of Map Data - Enabled
WriteRegKey "HKLM:\Software\Policies\Microsoft\Windows\Maps" "AutoDownloadAndUpdateMapData" "DWord" "0"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Game Explorer - Turn off tracking of last play time of games in the Games folder - Enabled
WriteRegKey "HKLM:\Software\Policies\Microsoft\Windows\GameUX" "ListRecentlyPlayed" "DWord" "0"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Game Explorer - Turn off game updates - Enabled
WriteRegKey "HKLM:\Software\Policies\Microsoft\Windows\GameUX" "GameUpdateOptions" "DWord" "0"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Game Explorer - Turn off downloading of game information - Enabled
WriteRegKey "HKLM:\Software\Policies\Microsoft\Windows\GameUX" "DownloadGameInfo" "DWord" "0"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Edge UI - Disable help tips - Enabled
WriteRegKey "HKLM:\Software\Policies\Microsoft\Windows\EdgeUI" "DisableHelpSticker" "DWord" "1"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Desktop Gadgets - Turn off desktop gadgets - Enabled
WriteRegKey "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Windows\Sidebar" "TurnOffSidebar" "DWord" "1"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Data Collection and Preview Builds - Toggle user control over Insider builds - Disabled
WriteRegKey "HKLM:\Software\Policies\Microsoft\Windows\PreviewBuilds" "AllowBuildPreview" "DWord" "0"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Data Collection and Preview Builds - Do not show feedback notifications - Enabled
WriteRegKey "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" "DoNotShowFeedbackNotifications" "DWord" "1"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Data Collection and Preview Builds - Disable pre-release features or settings - Disabled
WriteRegKey "HKLM:\Software\Policies\Microsoft\Windows\PreviewBuilds" "EnableConfigFlighting" "DWord" "0"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Data Collection and Preview Builds - Allow Telemetry - Enabled - Basic
#WriteRegKey "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" "DWord" "1"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Data Collection and Preview Builds - Allow Telemetry - Enabled - Setting 0
WriteRegKey "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" "DoNotShowFeedbackNotifications" "DWord" "1"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Cloud Content - Turn off Microsoft consumer experiences - Enabled
WriteRegKey "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" "DWord" "1"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Cloud Content - Do not show Windows tips - Enabled
WriteRegKey "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" "DisableSoftLanding" "DWord" "1"

#GPO - Computer Configuration/Administrative Templates/Windows Components/AutoPlay Policies - Turn off Autoplay - Enabled - Turn off Autoplay on: All Drives
WriteRegKey "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoDriveTypeAutoRun" "DWord" "255"

#GPO - Computer Configuration/Administrative Templates/System/User Profiles - Turn off the advertising ID - Enabled
WriteRegKey "HKLM:\Software\Policies\Microsoft\Windows\AdvertisingInfo" "DisabledByGroupPolicy" "DWord" "1"

#GPO - Computer Configuration/Administrative Templates/System/Logon - Show first sign-in animation  - Disabled
WriteRegKey "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" "EnableFirstLogonAnimation" "DWord" "0"

#GPO - Computer Configuration/Administrative Templates/System/Logon - Hide entry points for Fast User Switching - Enabled
WriteRegKey "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" "HideFastUserSwitching" "DWord" "1"

#Disable Action Center Notifications
WriteRegKey "HKLM:\Software\Policies\Microsoft\Windows\Explorer" "DisableNotificationCenter" "DWord" "1"

#Disable Domain Firewall Profile
WriteRegKey "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" "EnableFirewall" "DWord" "0"

#Disable Domain Firewall Profile Notifications
WriteRegKey "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" "DisableNotifications" "DWord" "1"

#Disable Public Firewall Profile
WriteRegKey "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile" "EnableFirewall" "DWord" "0"

#Disable Public Firewall Profile Notifications
WriteRegKey "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile" "DisableNotifications" "DWord" "1"

#Disable Standard Firewall Profile
WriteRegKey "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" "EnableFirewall" "DWord" "0"

#Disable Standard Firewall Profile Notifications
WriteRegKey "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" "DisableNotifications" "DWord" "1"

#Disable IE11 first run options
WriteRegKey "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_EUPP_GLOBAL_FORCE_DISABLE" "iexplore.exe" "DWord" "1"

#GPO - Computer Configuration/Administrative Templates/Windows Components/Internet Explorer - Prevent running First Run Wizard - Enabled-HomePage
WriteRegKey "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main" "DisableFirstRunCustomize" "DWord" "1"

#Disable new network discovery pop-up
WriteRegKey "HKLM:\System\CurrentControlSet\Control\Network\NetworkLocationWizard" "HideWizard" "DWord" "1"

#Configure Active Setup to disable network discovery pop-up
WriteRegKey "HKLM:\Software\Microsoft\Active Setup\Installed Components\DisableNetworkDiscoveryPrompt" "Version" "String" "1.0"
WriteRegKey "HKLM:\Software\Microsoft\Active Setup\Installed Components\DisableNetworkDiscoveryPrompt" "StubPath" "String" 'reg add HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Network\NwCategoryWizard /v "Show" /d "0" /f'

#Configure Active Setup for CMTrace
WriteRegKey "HKLM:\Software\Microsoft\Active Setup\Installed Components\CMTrace" "Version" "String" "1.0"
WriteRegKey "HKLM:\Software\Microsoft\Active Setup\Installed Components\CMTrace" "StubPath" "String" '"C:\Program Files\CMTrace\CMTraceFileSettings.cmd"'

#Configure Active Setup to disable Notification Center
WriteRegKey "HKLM:\Software\Microsoft\Active Setup\Installed Components\DisableNotificationCenter" "Version" "String" "1.0"
WriteRegKey "HKLM:\Software\Microsoft\Active Setup\Installed Components\DisableNotificationCenter" "StubPath" "String" 'reg add HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer /v "DisableNotificationCenter" /d "1" /f'

#Configure Active Setup for BGInfo Settings
WriteRegKey "HKLM:\Software\Microsoft\Active Setup\Installed Components\BGInfoSettings" "Version" "String" "1.0"
WriteRegKey "HKLM:\Software\Microsoft\Active Setup\Installed Components\BGInfoSettings" "StubPath" "String" 'reg add HKLM\SOFTWARE\Microsoft\WindowsNT\CurrentVersion\AppCompatFlags\Layers /v "C:\Program Files (x86)\Bginfo\Bginfo.exe" /d "~ HIGHDPIAWARE" /f'

#Configure Active Setup for Disable Spotlight
WriteRegKey "HKLM:\Software\Microsoft\Active Setup\Installed Components\DisableSpotlight" "Version" "String" "1.0"
WriteRegKey "HKLM:\Software\Microsoft\Active Setup\Installed Components\DisableSpotlight" "StubPath" "String" 'reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager /v "RotatingLockScreenEnabled" /d "0" /f'

#Configure Active Setup for Disable Tips on Lock Screen
WriteRegKey "HKLM:\Software\Microsoft\Active Setup\Installed Components\DisableTips" "Version" "String" "1.0"
WriteRegKey "HKLM:\Software\Microsoft\Active Setup\Installed Components\DisableTips" "StubPath" "String" 'reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager /v "SoftLandingEnabled" /d "0" /f'


#Enterprise Mode settings
WriteRegKey "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\EnterpriseMode" "Sitelist" "String" "https://myaccount.wendys.com/login/wendys_emie_sitelist.xml"
WriteRegKey "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\EnterpriseMode" "Enable" "String" " "

#Disable IE11 Welcome Screen
WriteRegKey "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main" "DisableFirstRunCustomize" "DWord" "00000001"

#Disable The Add-on is Ready popup bar
WriteRegKey "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Ext" "IgnoreFrameApprovalCheck" "DWord" "00000001"
WriteRegKey "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\Ext" "IgnoreFrameApprovalCheck" "DWord" "00000001"
 
#Disable NTLM V1 Hashing
WriteRegKey "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "LmCompatibilityLevel" "DWord" "00000003"

#Enable Strong Crypto for .NET 2
WriteRegKey "HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727" "SchUseStrongCrypto" "DWord" "00000001"
WriteRegKey "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727" "SchUseStrongCrypto" "DWord" "00000001"

#SMB signing on 445
WriteRegKey "HKLM:\System\CurrentControlSet\Services\LanMan\Server\Parameters" "RequireSecuritySignature" "DWord" "00000001"

#Disable WIFI Sense
WriteRegKey "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" "AutoConnectAllowedOEM" "DWord" "0"

#
WriteRegKey "HKLM:\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING" "iexplore.exe" "DWord" "1"
WriteRegKey "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING" "iexplore.exe" "DWord" "1"
WriteRegKey "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "CachedLogonsCount" "String" "2"
WriteRegKey "HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters" "RequireSecuritySignature" "DWord" "1"
WriteRegKey "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128" "Enabled" "DWord" "0"
WriteRegKey "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40/128" "Enabled" "DWord" "0"
WriteRegKey "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56/128" "Enabled" "DWord" "0"
WriteRegKey "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" "SecurityLayer" "DWord" "1" 
WriteRegKey "HKLM:\System\CurrentControlSet\Control\SecurityProviders \SCHANNEL\Protocols\PCT 1.0\Server" "Enabled" "DWord" "0"




#####Removed registry entries

#IE Home folders and delegated folders for x86 and x64
RemoveRegKey "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HomeFolderDesktop\NameSpace\DelegateFolders" "{3134ef9c-6b18-4996-ad04-ed5912e00eb5}"
RemoveRegKey "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HomeFolderDesktop\NameSpace\DelegateFolders" "{3936E9E4-D92C-4EEE-A85A-BC16D5EA0819}]"
RemoveRegKey "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\HomeFolderDesktop\NameSpace\DelegateFolders" "{3134ef9c-6b18-4996-ad04-ed5912e00eb5}"
RemoveRegKey "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\HomeFolderDesktop\NameSpace\DelegateFolders" "{3936E9E4-D92C-4EEE-A85A-BC16D5EA0819}"
