# Define the paths for Directory A and Directory B
$dirA = "\\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\Event Management Resources SharePoint"
$dirB = "C:\CHOA\Event Management Resources SharePoint"
$fileA = "C:\CHOA\copy-SharePointFiles.ps1"
$fileB = "\\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\Event Management Resources SharePoint\copy-SharePointFiles.ps1"


$localContent = Get-ChildItem -Path $dirA
foreach ($object in $localContent){
    Remove-Item $object -Force -Recurse
}

# Compare Directory A against Directory B
$itemsInA = Get-ChildItem -Path $dirA -Recurse
foreach ($item in $itemsInA) {
   # Calculate the relative path of the item
   $relativePath = $item.FullName.Substring($dirA.Length + 1)
   $comparePath = Join-Path $dirB $relativePath
   # If the item does not exist in B, remove it from A
   if (-not (Test-Path $comparePath)) {
       if ($item.PSIsContainer) {
           Remove-Item -Path $item.FullName -Recurse -Force
       } else {
           Remove-Item -Path $item.FullName -Force
       }
   }
}
# Compare Directory B against Directory A
$itemsInB = Get-ChildItem -Path $dirB -Recurse
foreach ($item in $itemsInB) {
   # Calculate the relative path of the item
   $relativePath = $item.FullName.Substring($dirB.Length + 1)
   $comparePath = Join-Path $dirA $relativePath
   # If the item does not exist in A, copy it from B to A
   if (-not (Test-Path $comparePath)) {
       if ($item.PSIsContainer) {
           Copy-Item -Path $item.FullName -Destination $comparePath -Recurse
       } else {
           Copy-Item -Path $item.FullName -Destination $comparePath
       }
   }
}

Copy-Item $fileA $fileB -Force

if (Test-Path '.\Event Management Resources'){
    Remove-Item 
}

Write-Host "Directory comparison and synchronization completed."