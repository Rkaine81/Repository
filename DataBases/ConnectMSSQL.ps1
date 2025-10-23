Import-Module sqlserver

$SqlServer    = 'dcvwp-sccmdb01' # SQL Server instance (HostName\InstanceName for named instance)
$Database     = 'CM_P01'      # SQL database to connect to 


$wSqlAuthLogin = 'sccmservice'                # SQL Authentication login
$wSqlAuthPw    = 'eUsBA(cn3s*izx$OmTLj09kz'   # SQL Authentication login password
$wInfVal2 = ConvertTo-SecureString $wSqlAuthPw -AsPlainText -Force
$wInfVal3 = New-Object System.Management.Automation.PSCredential ($wSqlAuthLogin, $wInfVal2)

#Local SQL Account
$SqlAuthLogin = 'ISTEngineeringAutomation'
$SqlAuthPw    = 'Secure5QLPa$$w0rD!'
$infVal2 = ConvertTo-SecureString $SqlAuthPw -AsPlainText -Force
$infVal3 = New-Object System.Management.Automation.PSCredential ($SqlAuthLogin, $infVal2)

# query to show changes
$Query = '
SELECT @@SERVERNAME AS [ServerName]
    , des.login_name
    , DB_NAME()   AS [DatabaseName]
    , dec.net_packet_size
    , @@LANGUAGE  AS [Language]
    , des.program_name
    , des.host_name
FROM sys.dm_exec_connections dec
JOIN sys.dm_exec_sessions des ON dec.session_id = des.session_id
WHERE dec.session_id = @@SPID
'

Invoke-Sqlcmd -ConnectionString "Data Source=$SqlServer; User Id=$SqlAuthLogin; Password =$SqlAuthPw; Encrypt=False; TrustServerCertificate=True;" -Query "$Query" 

Invoke-Sqlcmd -ConnectionString "Data Source=$SqlServer;Initial Catalog=$Database; Integrated Security=True; Encrypt=False; TrustServerCertificate=True" -Query "$Query" 

Invoke-Sqlcmd -Database $Database -Username $SqlAuthLogin -Password $SqlAuthPw -Query "$Query" -Encrypt Optional -TrustServerCertificate -ServerInstance $SqlServer


Invoke-Command -ComputerName dcvwp-sccmdb01 -Credential $wInfVal3 -Command {Invoke-Sqlcmd -ConnectionString "Data Source=$SqlServer;Initial Catalog=$Database; Integrated Security=True; Encrypt=False; TrustServerCertificate=True" -Query "$Query"}
