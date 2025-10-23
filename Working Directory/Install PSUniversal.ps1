Invoke-WebRequest https://imsreleases.blob.core.windows.net/universal/production/2.0.0/PowerShellUniversal.2.0.0.msi -OutFile Universal.msi
msiexec /i Universal.msi /qn
