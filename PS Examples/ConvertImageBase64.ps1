## Images
# Convert an image file to base64 string

$File = "C:\Users\179944\OneDrive - CHOA\Pictures\CHOAb.png"
$Image = [System.Drawing.Image]::FromFile($File)
$MemoryStream = New-Object System.IO.MemoryStream
$Image.Save($MemoryStream, $Image.RawFormat)
[System.Byte[]]$Bytes = $MemoryStream.ToArray()
$Base64 = [System.Convert]::ToBase64String($Bytes)
$Image.Dispose()
$MemoryStream.Dispose()
$Base64 | out-file "C:\Users\179944\OneDrive - CHOA\Pictures\ICON_CHOAb_LOGO_Resized.txt" # Save to text file, copy and paste from there to the $Base64Image variable
