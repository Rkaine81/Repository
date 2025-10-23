<#
Script Name: RemoveWindowsUpdates.ps1
Script Version: 1.0
Author: Adam Eaddy
Date Created: 04/28/2021
Date Updated: 
Description: The purpose of this script remove windows updates based on KB.
Changes:


Examples:
To uninstall a single KB: .\RemoveWindowsUpdates.ps1 -KBS "KB5001337"
To uninstall multiple KBs: .\RemoveWindowsUpdates.ps1 -KBS "KB5001337", "KB5001338"

/#>


param(
    [Parameter(Mandatory=$true)]
    [string]$KBS
    
)


foreach ($KB in $KBS) {

    $SearchUpdates = dism /online /get-packages | findstr "Package_for"
    $updates = $SearchUpdates.replace("Package Identity : ", "") | findstr $KB
    #$updates
    DISM.exe /Online /Remove-Package /PackageName:$updates /quiet /norestart

}