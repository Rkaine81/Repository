if (test-path "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe") {
    (Get-Item "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe").VersionInfo
}


if (test-path "C:\Program Files\Google\Chrome\Application\chrome.exe") {
    (Get-Item "C:\Program Files\Google\Chrome\Application\chrome.exe").VersionInfo
}



(Get-Item "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe").VersionInfo
(Get-Item "C:\Program Files\Microsoft\Edge\Application\msedge.exe").VersionInfo