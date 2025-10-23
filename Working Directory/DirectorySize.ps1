$dirs = Get-ChildItem -Path C:\ -Directory -Force -ErrorAction SilentlyContinue
foreach ($dir in $dirs) {
    if (($dir.name) -ne "Windows") {
        Write-Output "$($dir.fullname)."
        (Get-ChildItem ($dir.fullname) -force -Recurse -ErrorAction SilentlyContinue| measure Length -sum).sum / 1Gb
    }
}


$targetfolder='C:\'
$dataColl = @()
gci -force $targetfolder -ErrorAction SilentlyContinue | ? { $_ -is [io.directoryinfo] } | % {
    $len = 0
    gci -recurse -force $_.fullname -ErrorAction SilentlyContinue | % { $len += $_.length }
    $filesCount = (gci -recurse -force $_.fullname -File -ErrorAction SilentlyContinue | Measure-Object).Count
  $dataObject = New-Object PSObject -Property @{
        Folder = $_.fullname
        SizeGb = ('{0:N3}' -f ($len / 1Gb)) -as [single]
        filesCount=$filesCount
    }
   $dataColl += $dataObject
   }
$dataColl | Out-file -FilePath C:\CHOA\fileSize-C.txt

foreach ($dataCollObj in $dataColl) {
    if ($dataCollObj.sizeGB -gt 5) {
        Write-Output $dataCollObj.folder
    }
}