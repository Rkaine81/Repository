<#
Script Name: Remove_Windows_AppxPackage_Intune.ps1
Script Version: 1.0
Author: Adam Eaddy
Date Created: 04/19/2023
Date Updated: 
Description: The purpose of this script is to remove built in Windows "bloatware".
Changes:

/#>



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
 
 
# End Functions 



# Script Body 
 
 ### Remove Windows Apps ###

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
    )

    Try {
        foreach ($WindowsApp in $WindowsApps) {

            Write-Output "Removing $WindowsApp"
            Set-WindowsApps -AppName $WindowsApp
            Write-Output $FullMessage

        }
    }

    Catch{ 
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        $FullMessage = $Error[0].Exception.GetType().FullName
        Write-Output "Removing the Windows Apps failed: Error Details: $ErrorMessage; Target Object: $FailedItem; Full Error: $FullMessage"
    }



# End Script Body