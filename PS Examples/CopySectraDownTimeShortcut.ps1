$dest = "C:\Users\Public\Desktop\Sectra Downtime.url"

If (!(Test-Path "C:\Windows\Web\Icons")) {
    New-Item -ItemType Directory -Path C:\Windows\Web -Name Icons
}

If (!(Test-Path "C:\Windows\Web\Icons\EDTFinal.ico")) {
    Copy-Item "EDTFinal.ico" "C:\Windows\Web\Icons\EDTFinal.ico" -Force
}

If (!(test-path "C:\Users\Public\Desktop\Sectra Downtime.url")) {
    Copy-Item -Path "Sectra Downtime.url" $dest -Force
}