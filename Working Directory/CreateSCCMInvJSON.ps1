$LOCATION = get-content -Path "C:\Apps\CurrentLocation\Current.txt"

if (!(test-path "C:\Apps\CurrentLocation\Location.json")) { New-Item -Path "C:\Apps\CurrentLocation" -Name Location.json }

#Create JSON File
write-output "{" | Out-File "C:\Apps\CurrentLocation\location.json" -Force -Append
write-output "  ""ExtensionData"": {" | Out-File "C:\Apps\CurrentLocation\location.json" -Force -Append
write-output "    ""Location"":""$LOCATION""" | Out-File "C:\Apps\CurrentLocation\location.json" -Force -Append
write-output "  }" | Out-File "C:\Apps\CurrentLocation\location.json" -Force -Append
write-output "}" | Out-File "C:\Apps\CurrentLocation\location.json" -Force -Append