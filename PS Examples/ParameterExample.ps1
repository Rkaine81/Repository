    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('true', 'false')]
        [string]$A,
        [Parameter(Mandatory=$true)]
        [ValidateSet('true', 'false')]
        [string]$B,
        [Parameter(Mandatory=$true)]
        [ValidateSet('true', 'false')]
        [string]$C
    )


    if ($A -eq $true) {

    #Do Something
    new-item -ItemType directory -Path c:\temp\A

    }


    if ($B -eq $true) {

    #Do Something
    new-item -ItemType directory -Path c:\temp\B

    }

    
    if ($C -eq $true) {

    #Do Something
    new-item -ItemType directory -Path c:\temp\C

    }
