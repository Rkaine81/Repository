install-module -Name AZ


#Run this command - Use the 206676676 service account
Connect-AzAccount


#Select and run lines 8-14 to set East context

$sharename = "fslogix"
#$ProfileStorageAccount = "wvdazuresteast"
$ProfileStorageAccount = "wvdazurestwest"

$StorageAccountResourceGroupName = "RG-b137f49d-Infra-wu"

$context = Get-AzStorageAccount -ResourceGroupName $StorageAccountResourceGroupName -Name $ProfileStorageAccount


#Populate the SSO you are looking for and run lines 19-27

$SSO = "206676599"

$FileHandles = Get-AzStorageFileHandle -Context $context.context -ShareName $sharename -Recursive

foreach ($FileHandle in $FileHandles) {
    if ($FileHandle.Path -like "*206457222*"){
        Write-Output $FileHandle
    }
}



#Take the results from the last step and replace the value in filepath

$FilePath = "206457222_S-1-5-21-585568161-3286812181-671265034-1302629"

Close-AzStorageFileHandle -Context $context.context -ShareName $sharename -Path $FilePath -CloseAll -Recursive