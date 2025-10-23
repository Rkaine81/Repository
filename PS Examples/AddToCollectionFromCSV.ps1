$CSV1 = import-csv C:\choa\collMems2.csv -Header CollName, DevName

foreach ($obj1 in $CSV1) {
    #New-CMDeviceCollection -LimitingCollectionId P0100617 -Name $obj.name -RefreshType None
    Try
    {
        $devObjName = Get-CMDevice -Name $obj1.DevName
        Add-CMDeviceCollectionDirectMembershipRule -CollectionName ($obj1.CollName) -ResourceId ($devObjName.ResourceID)
    }
    Catch
    {
        write-output "$($obj1.DevName)" | out-file c:\choa\collMem2Errors.txt -Force -Append
    }

}