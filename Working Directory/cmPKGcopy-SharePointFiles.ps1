# Define the paths for Directory A and Directory B
$dirA = "C:\CHOA\IST\SupportTurnover\Event Management Resources"
$dirB = (pwd).Path


if (!(test-path $dirA)){
    New-Item -ItemType Directory $dirA
}

# Clean out the local directory to ensure all new files are copied. 
$localContent = Get-ChildItem -Path $dirA
foreach ($fobject in $localContent){
    Remove-Item $fobject.FullName -Force -Recurse
}

Start-Sleep 3

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

if (test-path "$dirA/copy-SharePointFiles.ps1"){
    Remove-Item "$dirA/copy-SharePointFiles.ps1" -Force
}

Write-Host "Directory comparison and synchronization completed."