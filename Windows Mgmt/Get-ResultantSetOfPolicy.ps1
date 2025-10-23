$User = "126833"
$Computer = "CHOA-8CC8372N2H"
Get-GPResultantSetOfPolicy -User $User -Computer $Computer -ReportType Html -Path "c:\choa\$Computer-gpoRemoteReport.html"