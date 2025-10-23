#Event log source 
$LogSource = "CHOA" 
New-EventLog -LogName Application -Source $LogSource -ErrorAction Ignore 
#Enable Shell launcher feature 
try { 
    #Write event log
    Write-EventLog -LogName Application -Source $LogSource -EntryType Info -EventId 1000 -Message "Start enable Shell Launcher Feature" 
    #Enable Shell launcher feature without restart 
    Enable-WindowsOptionalFeature -Online -FeatureName Client-EmbeddedShellLauncher -All -NoRestart -OutVariable result 
} catch { 
    # Something went wrong, display the error details and write an error to the event log 
    Write-EventLog -LogName Application -Source $LogSource -EntryType Warning -EventId 1001 -Message "$_.Exception.Message" 
}



#Event log source 
$LogSource = "CHOA" 
New-EventLog -LogName Application -Source $LogSource -ErrorAction Ignore 

# Create a function to retrieve the SID for a user account on a machine. 
function Get-UsernameSID($AccountName) { 
$NTUserObject = New-Object System.Security.Principal.NTAccount($AccountName) 
    try { 
        $NTUserSID = $NTUserObject.Translate([System.Security.Principal.SecurityIdentifier]) 
        return $NTUserSID.Value 
    } catch { 
        $ErrorMessage = $_.Exception.Message 
        Write-Error $ErrorMessage -Verbose 
    } 
} 


# Get the SID for a user account named. 
$KioskUser_SID = Get-UsernameSID("KioskUser") 
$COMPUTER = "localhost" 
$NAMESPACE = "root\standardcimv2\embedded" 

# Create a handle to the class instance so we can call the static methods. 
try { 

    Write-EventLog -LogName Application -Source $LogSource -EntryType Info -EventId 1001 -Message "Create a handle to the class instance" 
    $ShellLauncherClass = [wmiclass]"\\$COMPUTER\${NAMESPACE}:WESL_UserSetting" 

} catch [Exception] { 

    Write-Error $_.Exception.Message -Verbose 

} 

# Define actions to take when the shell program exits. 
$restart_shell = 0 
$restart_device = 1 
$shutdown_device = 2 
$do_nothing = 3 

try { 

    # Remove the old custom shells. 
    $ShellLauncherClass.RemoveCustomShell($KioskUser_SID) 

} catch [Exception] { 

    Write-Error $_.Exception.Message -Verbose Write-EventLog -LogName Application -Source $LogSource -EntryType Warning -EventId 1001 -Message "$_.Exception.Message" 

} 
try { 

    # Examples. You can change these examples to use the program that you want to use as the shell. 
    $ShellLauncherClass.SetDefaultShell("explorer.exe", $do_nothing) 

    # Display the default shell to verify that it was added correctly. 
    $DefaultShellObject = $ShellLauncherClass.GetDefaultShell() 
    Write-Error "Default Shell is set to $DefaultShellObject.Shell,and the default action is set to $DefaultShellObject.defaultaction" -Verbose 

    # Set Autologon as the shell for "KIOSKI" 
    $ShellLauncherClass.SetCustomShell($KioskUser_SID, "c:\program files\internet explorer\iexplore.exe www.microsoft.com", ($null), ($null), $restart_shell) 

    # Enable Shell Launcher 
    $ShellLauncherClass.SetEnabled($TRUE) 
    $IsShellLauncherEnabled = $ShellLauncherClass.IsEnabled() 
    Write-EventLog -LogName Application -Source $LogSource -EntryType info -EventId 1000 -Message "Custom Shell Launcher Feature enabled" 

} catch [Exception] { 

    $ErrorMessage = $_.Exception.Message 
    Write-Error $ErrorMessage -Verbose Write-EventLog -LogName Application -Source $LogSource -EntryType Warning -EventId 1001 -Message "Failed to Add custom Shell Launcher $($ErrorMessage)" 

}