try {
    # Code that might throw an exception
    $fileContent = Get-Content -Path "C:\path\to\your\file.txt"
    Write-Output "File content successfully read."
} catch {
    # Code to handle the error
    Write-Output "An error occurred: $_"
}