#1 Removing recycle bin files
$Path = 'C' + ':\$Recycle.Bin'
Get-ChildItem $Path -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Exclude *.ini -ErrorAction SilentlyContinue

#2 Remove Temp files from various locations  
$Path1 = 'C' + ':\Windows\Temp' 
Get-ChildItem $Path1 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue  
$Path2 = 'C' + ':\Windows\Prefetch' 
Get-ChildItem $Path2 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue  
$Path3 = 'C' + ':\Users\*\AppData\Local\Temp' 
Get-ChildItem $Path4 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

#3 Using Disk cleanup Tool  
cleanmgr /sagerun:1 | out-Null  
 


$disk1 = Get-PSDrive c
$free = $disk1.Free / 1GB

if ($free -lt 11)
{
    return $false
}else{
    return $true
}