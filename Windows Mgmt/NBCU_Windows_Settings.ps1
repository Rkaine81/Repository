<#
Script Name: ConfigureCoreWVDWIndowsSettings
Script Version: 1.0
Author: Adam Eaddy
Date Created: 04/06/2021
Description: The purpose of this script is to run on an initial setup of a WVD device.  This will configure "Computer Settings" via registry.  It will configure user settings by mounting NTUser.dat and setting default Registry settings. 
Changes:

/#>

### Local Account Settings (Not for WVD)###

#Reset Local Administrator Password


#Disable Local Administrator Account


#Rename Local Administrator Account to NBCUser1


#Disable Guest Account


#Rename Guest Account to NBCUAdmin (This is an intentional "honeypot".)



### Configure Windows Services ###

#Disable Credential Manager


#Disable Distributed Link Tracking Client


#Set Remote Registry to Automatic



### Windows Date and Time Settings ###

#Automatically Sync with Windows Time Server (time.windows.com)



### File Explorer options ###

#Open File Explorer to "This PC"


#Disbale Show recently used files in Quick Access


#Disable Show recently used folders in Quick Access


#Disable Quick Access Defaults (Desktop/Documents/Downloads/Pictures)


#Enable Always show icons, never thumbnails


#Enable Always show menus


#Enable Show Full path in the Title bar


#Disable Hide Empty Drives


#Disable Hide extentions for known file types


#Disable Hide Folder Merge Conflicts


#Enable Launch Folder Windows in a Separate Process


#Enable Restore Previous Folder Windows at Logon


#Enable Show encrypted or compressed NTFS files in color


#Disable Use Sharing Wizard



### Network and Sharing Center / Advanced Sharing ###

#Disable Network Discovery (Private/Guest-Public/Domain)


#Disable File and Print Sharing (Private/Guest Public)



### Advanced System Settings / Startup and Recovery ###

#Disable Automatically Restart on System Failure



### Advanced System Settings / Remote ###

#Disable Remote Assistance



### Troubleshooting / Change Settings ###

#Disable Computer Maintenance



### Windows Firewall / All ###

#Disable Firewall Service(s) and Notification(s)



### Notification and Actions ###

#Disable Get notifications from apps and other senders


#Disable Show notifications on the lock screen


#Disable Show reminders and incoming VOIP calls on the lock screen 


#Disable Get tips, tricks, and suggestions as you use Windows


#Disable Show me the Windows welcome experience screen after updates and occasionally when I sign in to highlight what’s new and suggested,



### Printers & Scanners ###

#Disable Let Windows manage my default printer



### Typing ###

#Autocorrect misspelled words I type (Hardware Keyboard)


#Enable Show text suggestions as I type (Hardware Keyboard)



### Autoplay ###

#Disable Use AutoPlay for all media and devices



### Gaming ###

#Disable Map updates – automatically update maps



### Privacy ###

#Disbale Let apps use my advertising ID to make ads more interesting to you based on your app usage


#Disable Let websites provide locally relevant content by accessing my language list



### Background Apps ###

#Disable Groove / Your Phone / XBOX


