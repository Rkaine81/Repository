$DONOTDELETE = "svc_Insight_prd",
"SNowSvc",
"Default",
"Administrator",
"Public",
"UEEService",
"systemprofile",
"LocalService",
"NetworkService"

$year = get-date -Format yyyy

$Profiles = Get-CimInstance win32_userprofile

foreach ($userProfile in $Profiles) {

    $profilePath = $userProfile.LocalPath
    $profileObj = Get-Item -Path $profilePath -force
    $dateTimeStr = ($profileObj.LastWriteTime).ToString()
    $dateStr = $dateTimeStr.TrimEnd().Split(' ')[0]
    $yearStr = $datestr.TrimStart().Split('/')[2]


    if ($yearStr -ne $year -and $DONOTDELETE -notcontains ($profileObj.Name)) {
        Write-Output "$($profileObj.Name) Not recent"
        Write-Output "Removing: $($profileObj.Name)."
        $userProfile | Remove-CimInstance

    }else{
        write-output "Leaving: $($profileObj.Name)."
    }

}

#((gci -force c:\Users -Recurse -ErrorAction SilentlyContinue| measure Length -s).sum / 1Gb) 