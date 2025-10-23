

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

install-module pendingreboot -Force

Test-PendingReboot -Detailed