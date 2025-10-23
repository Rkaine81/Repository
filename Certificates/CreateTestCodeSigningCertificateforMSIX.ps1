New-SelfSignedCertificate -Type Custom -Subject "CN=NBCU, O=WTE, C=AE" -KeyUsage DigitalSignature -FriendlyName "WTE Code Signing Cert" -CertStoreLocation "cert:\CurrentUser\my" -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}")  

$password = ConvertTo-SecureString -String abcd1234 -Force -AsPlainText 
Export-PfxCertificate -cert "Cert:\CurrentUser\My\977ead32b635c13d841f659d82398e6dc95ed497" -FilePath c:\temp\WTECodeSigning.pfx -Password $password