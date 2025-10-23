try {
    Start-Process "mypatch.exe" -argumentlist "/passive /norestart" -wait
} catch {
    # Catch will pick up any non zero error code returned
    # You can do anything you like in this block to deal with the error, examples below:
    # $_ returns the error details
    # This will just write the error
    Write-Host "mypatch.exe returned the following error $_"
    # If you want to pass the error upwards as a system error and abort your powershell script or function
    Throw "Aborted mypatch.exe returned $_"
}