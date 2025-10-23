


# 1. Input Your Variables
$tenantId = "dad3dd6a-c498-432c-82ce-86bb88b3d294"
$clientId = "05045b51-ce00-4802-8dfe-7ee60608a453"
$clientSecret = "eX78Q~20WkUgxfhFe2wdbVqjIn_VxGULY_CI1cW5"
$hostname = "choa365.sharepoint.com"  # Change this to your domain
$siteRelativePath = "/teams/IST-ServiceManagement"  # Change this to your site-relative path
$libraryName = "Documents"                # Typically "Documents", adjust if different
$folderRelativePath = "Event Mgmt. Resources"      # Folder path inside the library
$localDownloadPath = "C:\PS\Automations\Event Management Resources SharePoint\Downloads"  # Local path to save the files
$backupDir = "C:\PS\Automations\Event Management Resources SharePoint\Backup"
$backupFile = "Event Management Resources SharePoint Backup.zip"
$packageScript = "C:\PS\Automations\Event Management Resources SharePoint\copy-SharePointFiles.ps1"

# 2. Backup old files and prepare for new download
If (!(test-path "$backupDir\$backupFile")) {
    write-output "No backup. Creating backup."
    If (test-path $localDownloadPath) {
        if (test-path "$backupDir/$backupFile"){
            write-output "Removing old backup"
            Remove-Item -Path "$backupDir/$backupFile"
            Start-Sleep 2
            if (!(test-path "$backupDir/$backupFile")){
                Compress-Archive -Path $localDownloadPath -DestinationPath "$backupDir/$backupFile"
                if (test-path "$backupDir/$backupFile"){
                    Write-Output "Backup Successfull"
                } else {
                    Write-Output "Backup failed."
                    Exit 1
                }
            }
        }else{
            Compress-Archive -Path $localDownloadPath -DestinationPath "$backupDir/$backupFile"
            if (test-path "$backupDir/$backupFile"){
                Write-Output "Backup Successfull"
            } else {
                Write-Output "Backup failed."
                Exit 1
            }
        }
    }else{
        write-output "Directory does not exist.  Nothing to backup."
    }
}else{
    if (test-path "$backupDir/$backupFile"){
        write-output "Removing old backup"
        Remove-Item -Path "$backupDir/$backupFile"
        Start-Sleep 2
        if (!(test-path "$backupDir/$backupFile")){
            Compress-Archive -Path $localDownloadPath -DestinationPath "$backupDir/$backupFile"
            if (test-path "$backupDir/$backupFile"){
                Write-Output "Backup Successfull"
            } else {
                Write-Output "Backup failed."
                Exit 1
            }
        }
    }else{
        Compress-Archive -Path $localDownloadPath -DestinationPath "$backupDir/$backupFile"
        if (test-path "$backupDir/$backupFile"){
            Write-Output "Backup Successfull"
        } else {
            Write-Output "Backup failed."
            Exit 1
        }
    }
}

# 3. Delete existing SharePoint files
if ((test-path "$backupDir/$backupFile") -and (test-path $localDownloadPath)){
    Write-Output "Removing existing download directory."
    Remove-Item $localDownloadPath -Force -Recurse
}

# 4. Authenticate and Get an OAuth 2.0 Token
$tokenEndpoint = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$body = @{
   grant_type    = "client_credentials"
   client_id     = $clientId
   client_secret = $clientSecret
   scope         = "https://graph.microsoft.com/.default"
}
$response = Invoke-RestMethod -Uri $tokenEndpoint -Method Post -ContentType "application/x-www-form-urlencoded" -Body $body
$accessToken = $response.access_token
$headers = @{
   Authorization = "Bearer $accessToken"
}

# 5. Get the SharePoint Site ID
$siteApiUrl = "https://graph.microsoft.com/v1.0/sites/$hostname"+":$siteRelativePath"
$siteResponse = Invoke-RestMethod -Uri $siteApiUrl -Method Get -Headers $headers
$siteId = $siteResponse.id
# 6. Get the Drive ID for the "Documents" Library
$driveApiUrl = "https://graph.microsoft.com/v1.0/sites/$siteId/drives"
$driveResponse = Invoke-RestMethod -Uri $driveApiUrl -Method Get -Headers $headers
$drive = $driveResponse.value | Where-Object { $_.name -eq $libraryName }
if (-not $drive) {
   Write-Error "Could not find the '$libraryName' library."
   exit
}
$driveId = $drive.id

# 7. Funtion to download files and create directories
Function Get-SharePointData {
    param (
        [string]$driveIdF,            # The Drive ID of the SharePoint document library
        [string]$folderRelativePathF,  # The current folder path within the document library
        [string]$localFolderPathF,    # The local path to save files and folders
        [hashtable]$headersF          # Authorization headers
    )

    $folderApiUrlF = "https://graph.microsoft.com/v1.0/drives/$driveIdF/root:/$folderRelativePathF"+":/children"
    $folderContentsF = Invoke-RestMethod -Uri $folderApiUrlF -Method Get -Headers $headersF
    if (-not (Test-Path -Path $localFolderPathF)) {
        New-Item -Path $localFolderPathF -ItemType Directory | Out-Null
    }
    foreach ($item in $folderContentsF.value) {
        $itemName = $item.name
        if ($item.folder) {
            # If it's a folder, recursively call the function to download its contents
            $newRemotePath = "$folderRelativePathF/$itemName"
            $newLocalFolderPath = Join-Path $localFolderPathF $itemName
            Get-SharePointData -driveIdF $driveIdF -folderRelativePathF $newRemotePath -localFolderPathF $newLocalFolderPath -headersF $headersF
        } elseif ($item.file) {
            # If it's a file, download it
            $fileDownloadUrl = $item.'@microsoft.graph.downloadUrl'
            $localFilePath = Join-Path $localFolderPathF $itemName
            Invoke-RestMethod -Uri $fileDownloadUrl -Method Get -OutFile $localFilePath 
        }
    }

}

# 8. Call function
Get-SharePointData -driveIdF $driveId -folderRelativePathF $folderRelativePath -localFolderPathF $localDownloadPath -headersF $headers

# 9. Copy Package Script
if (!(test-path "$localDownloadPath\copy-SharePointFiles.ps1")) {
    Copy-Item $packageScript $localDownloadPath -Force
}

# 10. Copy Files to CIFS Share
$cifsPath = "\\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\Event Management Resources SharePoint"
$cifsBkup = "\\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\Event Management Resources SharePoint Backup"
$date = Get-Date -Format "MMddyyyy"

If (Test-path $cifsPath) {
    If (Test-path $cifsBkup) {
        # ZIP current files into bkup dir
        Compress-Archive $cifsPath "$cifsBkup\bkup.$date.zip"
        If (Test-path "$cifsBkup\bkup.$date.zip") {
            $fileToKeep = "bkup.$date.zip"
            $filesToDelete = Get-ChildItem -Path $cifsBkup -File | Where-Object { $_.Name -ne $fileToKeep }
            # Delete old backup
            foreach ($file in $filesToDelete) {
                Remove-Item -Path $file.FullName -Force
            }
        }
    }
    Remove-Item $cifsPath\* -Force -Recurse
    Copy-Item "$localDownloadPath\*" "$cifsPath" -Force -Recurse
}


