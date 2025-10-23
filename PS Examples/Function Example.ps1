function foo
{
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)]
    $inputobject
)

$output = $inputobject + 4
Write-Output $output
}

$var2 = foo -inputobject 1
$var2
