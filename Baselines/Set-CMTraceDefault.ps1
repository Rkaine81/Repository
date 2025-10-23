
#CfgItem Registry Value Exists

$regKey = "HKLM:\SOFTWARE\Classes\Log.File\shell\open\command"
$regValue = "Default"
$regValueProperty = "C:\Windows\CCM\CMTrace.exe"



function Test-RegistryKeyValue {
    <#
    .SYNOPSIS
    Tests if a registry value exists.

    .DESCRIPTION
    The usual ways for checking if a registry value exists don't handle when a value simply has an empty or null value.  This function actually checks if a key has a value with a given name.

    .EXAMPLE
    Test-RegistryKeyValue -Path 'hklm:\Software\Carbon\Test' -Name 'Title'

    Returns `True` if `hklm:\Software\Carbon\Test` contains a value named 'Title'.  `False` otherwise.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The path to the registry key where the value should be set.
        $Path,

        [Parameter(Mandatory=$true)]
        [string]
        # The name of the value being set.
        $Name
    )

    if( -not (Test-Path -Path $Path -PathType Container) )
    {
        return $false
    }

    $properties = Get-ItemProperty -Path $Path 
    if( -not $properties )
    {
        return $false
    }

    $member = Get-Member -InputObject $properties -Name $Name
    if( $member )
    {
        return $true
    }
    else
    {
        return $false
    }

}


if ((Test-RegistryKeyValue -Path $regKey -Name $regValue)) {

    #$Value = (Get-ItemProperty -path $regKey).$regValue
    if (((Get-ItemProperty -path $regKey).$regValue) -eq $regValueProperty) {
        return $true
    }else{
        return $false
    }
}else{
    return $false
}






# Create .Log and .Lo_ Keys to make CMTrace.exe the Default Log Viewer
New-Item -Path HKLM:\SOFTWARE\Classes\.lo_ -Value "Log.File" -Force -ErrorAction SilentlyContinue
New-Item -Path HKLM:\SOFTWARE\Classes\.log -Value "Log.File" -Force -ErrorAction SilentlyContinue
New-Item -Path HKLM:\SOFTWARE\Classes\Log.File\shell\open\command -Value "`"C:\Windows\CCM\CMTrace.exe`" `"%1`"" -Force -ErrorAction SilentlyContinue

#Create ActiveSetup to remove CMTrace question if it should be the Default Log Reader
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\CMtrace" -Force -ErrorAction SilentlyContinue
New-ItemProperty "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\CMtrace" -Name "Version" -Value 1 -PropertyType String -Force -ErrorAction SilentlyContinue
New-ItemProperty "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\CMtrace" -Name "StubPath" -Value "reg.exe ADD HKCU\Software\Microsoft\Trace32 /v ""Register File Types"" /d 0 /f" -PropertyType ExpandString -Force -ErrorAction SilentlyContinue