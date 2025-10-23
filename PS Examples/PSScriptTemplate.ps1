<#
Script Name: ConfigureWindowsSettingsForWDV.ps1
Script Version: 1.0
Author: Adam Eaddy
Date Created: 04/06/2021
Description: The purpose of this script is to set the Windows Security and Application settings on WDV devices.
Changes:
/#>

<#
Changes made by script:

LOCAL ACCOUNTS:
Set random PW on local Administrator account
Disable local Administrator account
Rename local Administrator account
Create NBCUAdmin account
Set Password for NBCUAdmin account
Disable Guest account
Rename Guest account to DONOTUSE
Set random PW on local Guest account

EVENT VIEWER:
Application: Maximum size when maximum log size is reached.
System:
Security:
hardware Events:
!!!Internet Explorer:
Key Management Service:
Media Center:
Windows PowerShell:


/#>