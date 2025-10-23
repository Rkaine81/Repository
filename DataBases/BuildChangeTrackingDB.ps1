import-module SqlServer



#Create Change Tables
<#
Invoke-Sqlcmd -ServerInstance USHDBWP00076\P0109ES01 -Database WTE_CHG_TRACKING -Query "CREATE TABLE C_Change ( ChangeNumber int NOT NULL IDENTITY PRIMARY KEY, Requester varchar(50) NULL, CI varchar(50) NULL, Date datetime NULL, Category varchar(50) NULL, Notification varchar(50) NULL, Impact varchar(50) NULL, Description varchar(MAX) NULL);"
Invoke-Sqlcmd -ServerInstance USHDBWP00076\P0109ES01 -Database WTE_CHG_TRACKING -Query "CREATE TABLE G_Categories ( CategoryNumber int NOT NULL IDENTITY PRIMARY KEY, CategoryName varchar(50) NULL);"
Invoke-Sqlcmd -ServerInstance USHDBWP00076\P0109ES01 -Database WTE_CHG_TRACKING -Query "CREATE TABLE G_Requester ( RequesterNumber int NOT NULL IDENTITY PRIMARY KEY, RequesterName varchar(50) NULL);"
Invoke-Sqlcmd -ServerInstance USHDBWP00076\P0109ES01 -Database WTE_CHG_TRACKING -Query "CREATE TABLE CI_OSD ( objID int NOT NULL IDENTITY PRIMARY KEY, Name varchar(50) NULL,ContentID varchar(50) NULL, ObjType varchar(50) NULL, Version int NULL);"
Invoke-Sqlcmd -ServerInstance USHDBWP00076\P0109ES01 -Database WTE_CHG_TRACKING -Query "CREATE TABLE CI_Patch ( objID int NOT NULL IDENTITY PRIMARY KEY, Name varchar(50) NULL,ContentID varchar(50) NULL, ObjType varchar(50) NULL, Version int NULL);"
Invoke-Sqlcmd -ServerInstance USHDBWP00076\P0109ES01 -Database WTE_CHG_TRACKING -Query "CREATE TABLE CI_Software ( objID int NOT NULL IDENTITY PRIMARY KEY, Name varchar(50) NULL,ContentID varchar(50) NULL, ObjType varchar(50) NULL, Version int NULL);"
Invoke-Sqlcmd -ServerInstance USHDBWP00076\P0109ES01 -Database WTE_CHG_TRACKING -Query "CREATE TABLE CI_Infrastructure ( objID int NOT NULL IDENTITY PRIMARY KEY, Name varchar(50) NULL,ContentID varchar(50) NULL, ObjType varchar(50) NULL, Version int NULL);"
Invoke-Sqlcmd -ServerInstance USHDBWP00076\P0109ES01 -Database WTE_CHG_TRACKING -Query "CREATE TABLE G_UAuthAudit ( objID int NOT NULL IDENTITY PRIMARY KEY, MessageID varchar(50) NULL, Componant varchar(50) NULL, System varchar(50) NULL, UserID varchar(50) NULL, Description varchar(MAX) NULL, Content varchar(50) NULL, Status varchar(50) NULL,);"

/#>


#Add data to Tabels

$VALUES = "OSD", "Patch", "Infrastructure", "Software"
$TABLE = "G_Categories"

foreach ($VALUE in $VALUES) {

    $insertquery="
    INSERT INTO [dbo].[$TABLE]
               ([CategoryName])
         VALUES
               ('$VALUE')
    GO
    "
    Invoke-Sqlcmd -ServerInstance USHDBWP00076\P0109ES01 -Database WTE_CHG_TRACKING -Query $insertquery

}



$VALUES1 = (Get-ADGroupMember -Identity "ADG-TM_ITWorkplaceDesktopEngineering").Name -replace("[~0-9\)\(\]\[]","") | where {$_ -notlike "svc Altiris" -and $_ -notlike "NBCUNI Ghost" -and $_ -notlike "*SCCM*"} | select -Unique | sort-object


$TABLE = "G_Requester"

foreach ($VALUE1 in $VALUES1) {

    $insertquery="
    INSERT INTO [dbo].[$TABLE]
               ([RequesterName])
         VALUES
               ('$VALUE1')
    GO
    "
    Invoke-Sqlcmd -ServerInstance USHDBWP00076\P0109ES01 -Database WTE_CHG_TRACKING -Query $insertquery

}

