# $erroractionpreference="stop"



<# Logging Function
Example: Write-Log "This is a log entry."
#>
Function Write-Log {

    param(
        [Parameter(Mandatory=$true)]
        [string]$VALUE
    )

    $LOGPATH = "C:\CHOA"
    #Set Log name
    $LOGFILE = "TeamsHealth.log"
    $FULLLOGPATH = "$LOGPATH\$LOGFILE"

    write-output "$(get-date): $VALUE" | out-file $FULLLOGPATH -Append -Force -NoClobber

}


$list = @(
    "$env:APPDATA", 
    "$env:APPDATA\Microsoft", 
    "$env:APPDATA\Microsoft\Crypto", 
    "$env:APPDATA\Microsoft\Internet Explorer", 
    "$env:APPDATA\Microsoft\Internet Explorer\UserData", 
    "$env:APPDATA\Microsoft\Internet Explorer\UserData\Low",
    "$env:APPDATA\Microsoft\Spelling", 
    "$env:APPDATA\Microsoft\SystemCertificates",
    "$env:APPDATA\Microsoft\Windows", 
    "$env:APPDATA\Microsoft\Windows\Libraries",
    "$env:APPDATA\Microsoft\Windows\Recent",
    "$env:LOCALAPPDATA",
    "$env:LOCALAPPDATA\Microsoft",
    "$env:LOCALAPPDATA\Microsoft\Windows",
    "$env:LOCALAPPDATA\Microsoft\Windows\Explorer",
    "$env:LOCALAPPDATA\Microsoft\Windows\History",
    "$env:LOCALAPPDATA\Microsoft\Windows\History\Low",
    "$env:LOCALAPPDATA\Microsoft\Windows\History\Low\History.IE5",
    "$env:LOCALAPPDATA\Microsoft\Windows\IECompatCache",
    "$env:LOCALAPPDATA\Microsoft\Windows\IECompatCache\Low",
    "$env:LOCALAPPDATA\Microsoft\Windows\IECompatUaCache",
    "$env:LOCALAPPDATA\Microsoft\Windows\IECompatUaCache\Low",
    "$env:LOCALAPPDATA\Microsoft\Windows\INetCache",
    "$env:LOCALAPPDATA\Microsoft\Windows\INetCookies",
    "$env:LOCALAPPDATA\Microsoft\Windows\INetCookies\DNTException",
    "$env:LOCALAPPDATA\Microsoft\Windows\INetCookies\DNTException\Low",
    "$env:LOCALAPPDATA\Microsoft\Windows\INetCookies\Low",
    "$env:LOCALAPPDATA\Microsoft\Windows\INetCookies\PrivacIE",
    "$env:LOCALAPPDATA\Microsoft\Windows\INetCookies\PrivacIE\Low",
    "$env:LOCALAPPDATA\Microsoft\Windows\PPBCompatCache",
    "$env:LOCALAPPDATA\Microsoft\Windows\PPBCompatCache\Low",
    "$env:LOCALAPPDATA\Microsoft\Windows\PPBCompatUaCache",
    "$env:LOCALAPPDATA\Microsoft\Windows\PPBCompatUaCache\Low",
    "$env:LOCALAPPDATA\Microsoft\WindowsApps",
    "$env:LOCALAPPDATA\Packages",
    "$env:LOCALAPPDATA\Publishers",
    "$env:LOCALAPPDATA\Publishers\8wekyb3d8bbwe",
    "$env:LOCALAPPDATA\Temp",
    "$env:USERPROFILE\AppData\LocalLow",
    "$env:USERPROFILE\AppData\LocalLow\Microsoft",
    "$env:USERPROFILE\AppData\LocalLow\Microsoft\Internet Explorer",
    "$env:USERPROFILE\AppData\LocalLow\Microsoft\Internet Explorer\DOMStore",
    "$env:USERPROFILE\AppData\LocalLow\Microsoft\Internet Explorer\EdpDomStore",
    "$env:USERPROFILE\AppData\LocalLow\Microsoft\Internet Explorer\EmieSiteList",
    "$env:USERPROFILE\AppData\LocalLow\Microsoft\Internet Explorer\EmieUserList",
    "$env:USERPROFILE\AppData\LocalLow\Microsoft\Internet Explorer\IEFlipAheadCache"
)

$ver = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\'
$script:osVersion = $ver.DisplayVersion
if($script:osVersion -eq "")    {
        $script:osVersion = $ver.ReleaseId
}
$script:osBuild = (Get-WmiObject -Class Win32_OperatingSystem).Version
$script:osUBR= [int]$ver.UBR
$script:osFullBuild = [version]"$script:osBuild.$script:osUBR"
$script:osProductName = $ver.ProductName
$SDATE = get-date -Format MMddyyyy
$LOGPATH = "C:\CHOA"
#Set Log name
$LOGFILE = "TeamsHealth_$SDATE.log"
$FULLLOGPATH = "$LOGPATH\$LOGFILE"
$script:errorCount = 0
If (test-path $FULLLOGPATH) {Remove-Item $FULLLOGPATH -Force}


function ValidateShellFolders
{
    $shellFolders = @(
        "Cookies",
        "Cache"
    )

$shellPaths = @{}

$path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"    
    $keys = Get-Item $path
    $props = Get-ItemProperty $path
    ($keys).Property | %{
        $shellPaths[$_] = $props."$_"
        $str = $props."$_"
        $str += "`t: " + $_
        #echo $str
    }

foreach($shellFolder in $shellFolders)
    {
        $shellPath = $shellPaths[$shellFolder]
        if(PathContainsReparsePoint($shellPath))
        {
            #Write-Warning "$($shellFolder) User Shell Folder path $shellPath contains a reparse point."
            Write-Log "FAIL: $($shellFolder) User Shell Folder path $shellPath contains a reparse point."
            $script:errorCount = $script:errorCount + 1
        }
        else
        {
            #Write-Host "$($shellFolder) User Shell Folder path $shellPath is not a reparse point" -ForegroundColor Green
            Write-Log "PASS: $($shellFolder) User Shell Folder path $shellPath is not a reparse point"
        }
    }
}

function ValidateEnvironmentVars
{
    $temps = (gci env:* | ?{@("TEMP", "TMP").Contains($_.Name)})
    foreach($temp in $temps)
    {
        if(IsReparsePoint($temp.Value))
        {
            #Write-Warning "$($temp.Name): $($temp.Value) is a reparse point"
            Write-WLog "FAIL: $($temp.Name): $($temp.Value) is a reparse point"
            $script:errorCount = $script:errorCount + 1
        }
        else
        {
            #Write-Host "$($temp.Name): $($temp.Value) is not a reparse point" -ForegroundColor Green
            Write-Log "PASS:$($temp.Name): $($temp.Value) is not a reparse point"
        }
    }
}

function ValidatePaths($list)
{
    Foreach ($path in $list)
    {
        if (Test-Path -Path $path)
        {
            if (Test-Path -Path $path -PathType Container)
            {
                #Write-Host "Folder: $path" -ForegroundColor Green
                Write-Log "PASS: Folder: $path"
            }
            else
            {
                #Write-Warning "FILE: $path"
                Write-Log "FAIL: Folder: $path"
            }
        }
        else
        {
            #Write-Host "MISSING: $path" -ForegroundColor Green
            Write-Log "MISSING: $path"
        }
    }
}

function IsReparsePoint([string]$path) 
{

$props = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue
    if($props.Attributes -match 'ReparsePoint')
    {
        return $true
    }
    return $false
}

function PathContainsReparsePoint($path, $trace = $false)
{
    $badPaths = 0
    $result = ""
    $left = $path
    for($i=0;$i -lt 10; $i++)
    {
        if ([string]::IsNullOrEmpty($left))
        {
            break;
        };
        if(IsReparsePoint($left))
        {
            $result = "Y" + $result
            $badPaths++
        }
        else{
            $result = "N" + $result
        }
        $left=Split-Path $left
    }
    if($trace)
    {
        if ($result.Contains("Y"))
        {
            #Write-Warning "$result $path contains a reparse point"
            Write-Log "FAIL: $result $path contains a reparse point"
            $script:errorCount = $script:errorCount + 1
        }
        else
        {
            #Write-Host "$result $path" -ForegroundColor Green
            Write-Log "PASS: $result $path" 
        }
    }
    return $badPaths -gt 0
}

function ValidateAppXPolicies()
{
    $osPatchThresholds = @{
        "10.0.19044" = 4046 #Win 10 21H2
        "10.0.19045" = 3636 #Win 10 22H2
        "10.0.22000" = 2777 #Win 11 21H2
        "10.0.22621" = 2506 #Win 11 22H2
    }

$minPatchVersion = [version]"10.0.19044"
    $maxPatchVersion = [version]"10.0.22621"

if($script:osFullBuild -lt $minPatchVersion)
    {
        if(-Not (HasAllowAllTrustedAppsKeyEnabled))
        {
            #Write-Warning "AllowAllTrustedApps is not enabled and OS version is too low to get the AllowAllTrustedApps patch."
            Write-Log "FAIL: AllowAllTrustedApps is not enabled and OS version is too low to get the AllowAllTrustedApps patch."
            $script:errorCount = $script:errorCount + 1
        }
        else
        {
            #Write-Host "The OS version is too low to get the AllowAllTrustedApps patch, but AllowAllTrustedApps is a supported value" -ForegroundColor Green
            Write-Log "PASS: The OS version is too low to get the AllowAllTrustedApps patch, but AllowAllTrustedApps is a supported value"
        }
    }
    elseif($script:osFullBuild -le $maxPatchVersion)
    {
        $targetUBR = $osPatchThresholds[$script:osBuild]
        if($script:osUBR -lt $targetUBR)
        {
            if(-Not (HasAllowAllTrustedAppsKeyEnabled))
            {
                $recommendedVersion = [version]"$script:osBuild.$targetUBR"
                #Write-Warning "AllowAllTrustedApps is not enabled and your version of Windows does not contain a required patch to support this.`nEither update your version of Windows to be greater than $recommendedVersion, or enable AllowAllTrustedApps"
                Write-Log "FAIL: AllowAllTrustedApps is not enabled and your version of Windows does not contain a required patch to support this.`nEither update your version of Windows to be greater than $recommendedVersion, or enable AllowAllTrustedApps"
                $script:errorCount = $script:errorCount + 1
            }
            else
            {
                #Write-Host "OS version is missing the AllowAllTrustedApps patch, but AllowAllTrustedApps is a supported value" -ForegroundColor Green
                Write-Log "PASS: OS version is missing the AllowAllTrustedApps patch, but AllowAllTrustedApps is a supported value"
            }
        }
        else
        {
            #Write-Host "OS version has the AllowAllTrustedApps patch"
            Write-Log "PASS: OS version has the AllowAllTrustedApps patch" -ForegroundColor Green
        }
    }
    else
    {
        #Write-Host "OS version is high enough that AllowAllTrustedApps should not be an issue" -ForegroundColor Green
        Write-Log "PASS: OS version is high enough that AllowAllTrustedApps should not be an issue"
    }
}

function HasAllowAllTrustedAppsKeyEnabled
{
    $hasKey = $false;
    $appXKeys = @("HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock", "HKLM:\Software\Policies\Microsoft\Windows\Appx")
    foreach ($key in $appXKeys)
    {
        try
        {
            $value = Get-ItemPropertyValue -Path $key -Name "AllowAllTrustedApps"
            #echo "$key AllowAllTrustedApps = $value"
            Write-Log "$key AllowAllTrustedApps = $value"
            if ($value -ne 0) 
            {
                $hasKey = $true
                break;
            }
        }
        catch
        {
            #echo "Missing AllowAllTrustedApps key at $key"
            Write-Log "Missing AllowAllTrustedApps key at $key"
        }
    }
    return $hasKey
}

#echo "$script:osProductName Version $script:osVersion, Build $script:osFullBuild"
Write-Log "$script:osProductName Version $script:osVersion, Build $script:osFullBuild"
#echo ""
#echo "# Checking for reparse points in user shell folders"
Write-Log "# Checking for reparse points in user shell folders"
ValidateShellFolders
#echo ""
#echo "# Checking for reparse points in temp/tmp environment variables"
Write-Log "# Checking for reparse points in temp/tmp environment variables"
ValidateEnvironmentVars
#echo ""
#echo "# Checking for reparse points in appdata"
Write-Log "# Checking for reparse points in appdata"
foreach ($path in $list)
{
    $result = PathContainsReparsePoint $path $true
}
#echo ""
#echo "# Checking for unexpected files in appdata"
Write-Log "# Checking for unexpected files in appdata"
ValidatePaths($list)
#echo ""
#echo "# Checking if AllowAllTrustedApps is valid"
Write-Log "# Checking if AllowAllTrustedApps is valid"
ValidateAppXPolicies


if ($script:errorCount -eq 0) {
    return $true
}else{
    return $false
}
