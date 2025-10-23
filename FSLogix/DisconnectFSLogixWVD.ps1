<#
Script Name: DisconnectFSLogixDiskWVD.ps1
Script Version: 1.0
Author: Adam Eaddy
Edited by: 
Date Created: 29/12/2021
Date Updated: 
Description: The purpose of this script is to disconnect an azure file lock on FSLogix profile disks.  This script must be run on a device that can connect to the Azure environment.  
             When it runs, you should be prompted for credentials with access. 
Usage:  
    Query: This section is run first to validate there is a locked File Handle for the SSO
    DisconnectFSLogixWVD.ps1 -SSO 206676599 -ValidateSet query

    Remove: This section is run second to remove the File Handle Lock.
    DisconnectFSLogixWVD.ps1 -SSO 206676599 -ValidateSet remove

Changes:

/#>

    param(
        [Parameter(Mandatory=$true)]
        [string]$SSO,
        [Parameter(Mandatory=$true)]
        [ValidateSet('query','remove')]
        [string]$runMode

    )


if ((Get-Module -Name AZ.Storage -ListAvailable) -eq $null) {
    cls
    Write-Host -ForegroundColor Yellow 'The module "AZ.Storage" is not installed.
    Installing the "AZ" Module.
    This may take a few minutes. Please be patient.'
    install-module -Name AZ -Force -AllowClobber
        if ((Get-Module -Name AZ.Storage -ListAvailable) -eq $null) {
            cls
            Write-Host -ForegroundColor Yellow 'The module "AZ.Storage" is not installed.
            Attempting the module installation again.
            This may take a few minutes. Please be patient.'
            install-module -Name AZ -Force -Scope CurrentUser
        }else{
            cls
            write-host -ForegroundColor Green 'The "AZ.Storage" module is successfully installed.'
        }
}else{
    cls
    write-host -ForegroundColor Green 'The "AZ.Storage" module is successfully installed.
    '
}






Connect-AzAccount


$sharename = "fslogix"
$ProfileStorageAccountEast = "wvdazuresteast"
$ProfileStorageAccountWest = "wvdazurestwest"
$StorageAccountResourceGroupName = "RG-b137f49d-Infra-wu"
$contextEast = Get-AzStorageAccount -ResourceGroupName $StorageAccountResourceGroupName -Name $ProfileStorageAccountEast
$contextWest = Get-AzStorageAccount -ResourceGroupName $StorageAccountResourceGroupName -Name $ProfileStorageAccountWest


if ($runMode -eq "query"){

    $FileHandlesEast = Get-AzStorageFileHandle -Context $contextEast.context -ShareName $sharename -Recursive 

    foreach ($FileHandleEast in $FileHandlesEast) {
        if ($FileHandleEast.Path -like "*$SSO*"){
            cls
            Write-Output "The file lock for $SSO has been found on the WVDAzurestEast share."
            Write-Output $FileHandleEast                   


        }
    }


    $FileHandlesWest = Get-AzStorageFileHandle -Context $contextWest.context -ShareName $sharename -Recursive

    foreach ($FileHandleWest in $FileHandlesWest) {
        if ($FileHandleWest.Path -like "*$SSO*"){
            cls
            Write-Output "The SSO $SSO has been found on the WVDAzurestWest FSLogix share."
            Write-Output $FileHandleWest


        }
    }

}

if ($runMode -eq "remove"){

    $FileHandlesEast = Get-AzStorageFileHandle -Context $contextEast.context -ShareName $sharename -Recursive 

    foreach ($FileHandleEast in $FileHandlesEast) {
        if ($FileHandleEast.Path -like "*$SSO*"){            
            Write-Output "Removing file locks."
            $FileHandlePath = $FileHandleEast.Path.Substring(0, $FileHandleEast.Path.Length -23)
            Close-AzStorageFileHandle -Context $contexteast.context -ShareName $sharename -Path $FileHandlePath -CloseAll -Recursive
            Write-Output "Removed file locks."
        


        }
    }


    $FileHandlesWest = Get-AzStorageFileHandle -Context $contextWest.context -ShareName $sharename -Recursive

    foreach ($FileHandleWest in $FileHandlesWest) {
        if ($FileHandleWest.Path -like "*$SSO*"){
            Write-Output "Removing file locks."
            $FileHandlePath = $FileHandleWest.Path.Substring(0, $FileHandleWest.Path.Length -23)
            Close-AzStorageFileHandle -Context $contextwest.context -ShareName $sharename -Path $FileHandlePath -CloseAll -Recursive
            Write-Output "Removed file locks."


        }
    }

}