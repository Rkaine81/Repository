


#  GPO Settings
$gpoSettings=@(
@("hklm:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "SettingsPageVisibility", "String", "ShowOnly:mousetouchpad;printers;network-ethernet;network-status;network;network-wifi;display"),           #Settings Page Visibility
@("hkcu:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "RestrictCpl", "Dword", "1"),                                                                                                                  #Show only specified Control Panel items
@("hkcu:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\RestrictCpl", "1", "String", "Microsoft.Mouse"),                                                                                                 #Show only specified Control Panel item 1
@("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "HideIcons", "Dword", "1"),                                                                                                                    #Remove icons on the desktop
@("hkcu:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoViewContextMenu ", "Dword", "1"),                                                                                                           #Remove File Explorer's default context menu
@("hkcu:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoWinKeys", "Dword", "1"),                                                                                                                    #Turn off Windows Key hotkeyss
@("hkcu:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoViewOnDrive", "Dword", "3ffffff"),                                                                                                          #Prevent access to drives from My Computer
@("hkcu:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "DisallowRun", "Dword", "1"),                                                                                                                  #Don't run specified Windows applications
@("hkcu:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun", "1", "String", "Explorer.exe"),                                                                                                    #Don't run specified Windows applications 1
@("hkcu:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun", "2", "String", "Regedit.exe"),                                                                                                     #Don't run specified Windows applications 2
@("hkcu:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun", "3", "String", "cscript.exe"),                                                                                                     #Don't run specified Windows applications 3
@("hkcu:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun", "4", "String", "calc.exe"),                                                                                                        #Don't run specified Windows applications 4
@("hkcu:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun", "5", "String", "defrag.exe"),                                                                                                      #Don't run specified Windows applications 5
@("hkcu:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun", "6", "String", "MicrosoftEdge.exe"),                                                                                               #Don't run specified Windows applications 6
@("hkcu:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun", "7", "String", "mmc.exe"),                                                                                                         #Don't run specified Windows applications 7
@("hkcu:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun", "8", "String", "powershell.exe"),                                                                                                  #Don't run specified Windows applications 8
@("hkcu:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun", "9", "String", "powershell_ise.exe"),                                                                                              #Don't run specified Windows applications 9
@("hkcu:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun", "10", "String", "wmplayer.exe"),                                                                                                   #Don't run specified Windows applications 10
@("hkcu:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun", "11", "String", "wordpad.exe"),                                                                                                    #Don't run specified Windows applications 11
@("hkcu:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun", "12", "String", "notepad.exe"),                                                                                                    #Don't run specified Windows applications 12
@("hkcu:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun", "13", "String", "wscript.exe"),                                                                                                    #Don't run specified Windows applications 13
@("hkcu:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun", "14", "String", "write.exe"),                                                                                                      #Don't run specified Windows applications 14
@("hkcu:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun", "15", "String", "cmd.exe"),                                                                                                        #Don't run specified Windows applications 15
@("hkcu:\Software\CHOA", "Lockdown", "Dword", "1"))                                                                                                                                                                   #CHOA key to validate settings are applied



 Function WriteRegKey{
 #Create registry path if it doesn't exist. Then modify entry value. 
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
        New-ItemProperty -Path $registryPath -Name $regName -PropertyType $regType -Value $regValue -Force
    #}
    
    #Catch{AppendLog "$((Get-PSCallStack)[1].Command) Set Registry Value failed: $LASTEXITCODE; Error Details: $($_.ErrorDetails); Error Stack Trace: $($_.ScriptStackTrace); Target Object: $($_.TargetObject); Invocation Info: $($_.InvocationInfo)"}

}

foreach ($gpoSetting in $gpoSettings) {


    $regKey = $gpoSetting[0]
    $regValue = $gpoSetting[1]
    $regType = $gpoSetting[2]
    $regValueProperty = $gpoSetting[3]

    WriteRegKey $regKey $regValue $regType $regValueProperty

}