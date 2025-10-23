# =============================================================================================================================
# Author:       Mietek Rogala
# Filename:     Get-ContentStatus.ps1
#
# Notes:
# Scripts purpose is to query Task Sequence by ID and generate comprehensive content report.
# The script will generate a HTML report in the current directory called <TaskSequenceId>.html, unless otherwise specified.
# The script will query all Distribution Points, unless a list of distribution points is specified.
#
# Dependencies:
#   - Configuration Manager module must be imported prior to running the script.
#
# Script usage:
# [import-module "<path_to_CM_admin_console_install_dir>\bin\ConfigurationManager.psd1"]
# .\Get-ContentStatus.ps1 -SiteCode <sitecode> -TaskSequenceID <TS_id> [-ReportFileName <full_path_to_html_report>] [-DistributionPoints <Distribution_Points_list>]
#
# Examples:
# .\Get-ContentStatus.ps1 -SiteCode DEV -TaskSequenceID DEV0001E
# .\Get-ContentStatus.ps1 -SiteCode P01 -TaskSequenceID P0100357 -ReportFileName "C:\Temp\content_report.html"
# .\Get-ContentStatus.ps1 -SiteCode P01 -TaskSequenceID P0100366 -DistributionPoints DP1.FQDN.COM,DP2.FQDN.COM,DP3.FQDN.COM
#
# =============================================================================================================================
 
[CmdletBinding()]
#Requires -Version 3.0
#Requires -Modules ConfigurationManager 
 
Param
( 
 
    # The Site Code for the Config Manager Site you wish to perform the check against.
    [Parameter(Mandatory=$true)]
    [String]$SiteCode,
    # The Task Sequence ID to be queried
    [Parameter(Mandatory=$true)]
    [String]$TaskSequenceID,
    # The output file name to write report to.
    [Parameter(Mandatory=$false)]
    [String]$ReportFileName,
    # List of distribution points to be queried (script will query all DPs if not specified). Must be FQDN.
    [Parameter(Mandatory=$false)]
    [String[]]$DistributionPoints
) 
 
############################################################## Functions ##############################################################
 
# Function to connect to SCCM if not already connected
Function Connect-ToSCCM
{
    # Navigate to site code context if not already connected
    If((Get-Location).Drive.Name -ne $SiteCode)
    {
        Try
        {
            Set-Location -path "$($SiteCode):" -ErrorAction Stop
        }
        Catch
        {
            Throw "Unable to connect to Configuration Manager site $SiteCode."
        }
    }
}
 
# Function to obtain list of all Distribution Points in the environment
Function Get-DistributionPointsList
{
    # Connect to SCCM if needed
    Connect-ToSCCM
 
    # Get all Distribution Point names
    $DistributionPointsList = (Get-CMDistributionPointInfo | select Name).Name
 
    # Get DP names using fall-back method (if Get-CMDistributionPointInfo fails)
    If(!($DistributionPointsList))
    {
        write-host "$(Get-Date -format 'u') # Using fallback method to fetch the list of Distribution Points..."
        # Get all Distribution Point names
        $DistributionPointsList = ((Get-CMDistributionPoint | select NetworkOSPath).NetworkOSPath -replace "\\","")
    }
    return $DistributionPointsList
}
 
# Function to obtain status of all packages
Function Get-TaskSequenceContentStatus
{
    Param
    ( 
 
        # The Task Sequence ID to be queried
        [Parameter(Mandatory=$true)]
        [String]$TaskSequenceID,
 
        # List of distribution points to be queried. Must be FQDN.
        [Parameter(Mandatory=$false)]
        [String[]]$DistributionPoints
    )
    # Connect to SCCM if needed
    Connect-ToSCCM
 
    # Get ConfigMgr site server name
    $CMSiteServerName = $(Get-CMSite -SiteCode $SiteCode|select ServerName).ServerName 
 
    # Get Task Sequence properties
    write-host "$(Get-Date -format 'u') # Getting list of packages associated with "$TaskSequenceID"..."
    $TaskSequenceInfo = Get-CMTaskSequence -TaskSequencePackageId $TaskSequenceID
 
    # Select all packages' IDs
    $TaskSequencePackages = $TaskSequenceInfo.References | select Package
 
    # Placeholder for fallback method of apps discovery
    $AppsList = $null
 
    # Array used for storing the info
    $arContentStatusInfo = @()
 
    # Set counter
    $currentPackageNo = 0
 
    # Select only unique package references
    $TaskSequenceUniquePackages = $TaskSequencePackages | select Package -uniq
    write-host "$(Get-Date -format 'u') # Querying "$DistributionPoints.Count" Distribution Points for status of "$TaskSequenceUniquePackages.Count" packages"
 
    # Loop through all the package IDs in the Task Sequence
    ForEach ($Package in $TaskSequenceUniquePackages.Package)
    {
        $currentPackageNo++
        write-host "$(Get-Date -format 'u') # Processing packge "$currentPackageNo" out of " $TaskSequenceUniquePackages.Count "..."
        $ResourceType = ""
 
        # Try if the package is of 'Package' type
        $CurrentPackage = (Get-CMPackage -Id $Package | Select-object Name).Name
        If(($CurrentPackage)) { $ResourceType = "Package" }
 
        # Try if the package is of 'Driver Package' type
        If(!($CurrentPackage))
        {
            $CurrentPackage = (Get-CMDriverPackage -Id $Package | Select-object Name).Name
            If(($CurrentPackage)) { $ResourceType = "Driver Package" }
        }
 
        # Try if the package is of 'Operating System Install Package' type
        If(!($CurrentPackage))
        {
            $CurrentPackage = (Get-CMOperatingSystemImage  -Id $Package | Select-object Name).Name
            If(($CurrentPackage)) { $ResourceType = "Operating System Install Package" }
        }
 
        # Try if the package is of 'Boot Image Package' type
        If(!($CurrentPackage))
        {
                $CurrentPackage = (Get-CMBootImage -Id $Package | Select-object Name).Name
            If(($CurrentPackage)) { $ResourceType = "Boot Image Package" }
        }
 
        # Try if the package is of 'Application' type
        If(!($CurrentPackage))
        {
            $CurrentPackage = (Get-CMApplication -ModelName $Package | Select-object LocalizedDisplayName).LocalizedDisplayName
            If($CurrentPackage)
            {
                $Package = (Get-CMApplication -ModelName $Package | Select-object PackageID).PackageID
                $ResourceType = "Application"
            }
            Else
            {
                # Fall-back method, slower.
                write-host "$(Get-Date -format 'u') # Using fallback method to get the application info..."
 
                # Cache results if running for the first time
                If(!($AppsList))
                {
                    # Get default CM query limit
                    $defaultCMQueryLimit = Get-CMQueryResultMaximum
 
                    # Temporarily change CM query limit to maximum allowed to cache all applications
                    Set-CMQueryResultMaximum -Maximum 100000
 
                    write-host "$(Get-Date -format 'u') # Caching application information for fallback query method, this may take some time..."
                    $AppsList = (Get-CMApplication | Select-Object PackageID,ModelName,LocalizedDisplayName)
 
                    write-host "$(Get-Date -format 'u') # Caching complete."
                    # Restore default CM query limit
                    Set-CMQueryResultMaximum -Maximum $defaultCMQueryLimit
                }
 
                # Go through cached results to find the application package info
                ForEach($App in $AppsList)
                {
                    If($App.ModelName -eq "$Package")
                    {
                        $CurrentPackage = $App.LocalizedDisplayName
                        $Package = $App.PackageID
                        $ResourceType = "Application"
                    }
                }
            }
        }
        If(!($CurrentPackage))
        {
            $ResourceType = "Unknown"
        }
        $currentDPNo = 0
        write-host "$(Get-Date -format 'u') # Package ID: " $Package " Package type: " $ResourceType " Package name: " $CurrentPackage
 
        # Loop through all DPs
        ForEach($DP in $DistributionPoints)
        {
            $currentDPNo++
 
            # Query status of a specific package on a specific DP
            $ContentWMIquery = Get-WmiObject –NameSpace Root\SMS\Site_$SiteCode –Class SMS_DistributionDPStatus -ComputerName $CMSiteServerName –Filter "PackageID='$Package' And Name='$DP'" | Select Name, MessageID, MessageState, LastUpdateDate, ObjectTypeID
 
            # If no results returned - assume the DP is not targeted for the package
            If($ContentWMIquery -eq $null)
            {
                $Status = "Not targeted"
                $Message = "No status found! Ensure the package content has been deployed to this distribution point." 
 
                $arContentStatusInfo += [PSCustomObject]@{
                    'Name' = $CurrentPackage
                    'PackageID' = $Package
                    'ResourceType' = $ResourceType
                    'Distribution Point'= $DP
                    'Status' = $Status
                    'Message' = $Message
                }
            }
            Else
            {
                Foreach ($objItem in $ContentWMIquery)
                {
                    $DPName = $null
                    $DPName = $objItem.Name
                    $UpdDate = [System.Management.ManagementDateTimeconverter]::ToDateTime($objItem.LastUpdateDate) 
 
                    # Get package status
                    switch ($objItem.MessageState)
                    {
                        1{$Status = "Success"}
                        2{$Status = "In Progress"}
                        3{$Status = "Unknown"}
                        4{$Status = "Failed"}
                    }
 
                    # Get package status message
                    switch ($objItem.MessageID)
                    {
                        2303{$Message = "Content was successfully refreshed"}
                        2323{$Message = "Failed to initialize NAL"}
                        2324{$Message = "Failed to access or create the content share"}
                        2330{$Message = "Content was distributed to distribution point"}
                        2354{$Message = "Failed to validate content status file"}
                        2357{$Message = "Content transfer manager was instructed to send content to Distribution Point"}
                        2360{$Message = "Status message 2360 unknown"}
                        2370{$Message = "Failed to install distribution point"}
                        2371{$Message = "Waiting for prestaged content"}
                        2372{$Message = "Waiting for content"}
                        2380{$Message = "Content evaluation has started"}
                        2381{$Message = "An evaluation task is running. Content was added to Queue"}
                        2382{$Message = "Content hash is invalid"}
                        2383{$Message = "Failed to validate content hash"}
                        2384{$Message = "Content hash has been successfully verified"}
                        2391{$Message = "Failed to connect to remote distribution point"}
                        2398{$Message = "Content Status not found"}
                        8203{$Message = "Failed to update package"}
                        8204{$Message = "Content is being distributed to the distribution Point"}
                        8211{$Message = "Failed to update package"}
                    }
 
                    $arContentStatusInfo += [PSCustomObject]@{
                    'Name' = $CurrentPackage
                    'PackageID' = $Package
                    'ResourceType' = $ResourceType
                    'Distribution Point'= $DPName
                    'Status' = $Status
                    'Message' = $Message
                    }
                } # Distribution Status Foreach
            } # DP result query If
        } # $DP Foreach
    } # Package Foreach
 
    write-host "$(Get-Date -format 'u') # Finished processing all packages on all Distribution Points."
    return $arContentStatusInfo
}
########################################################### End of Functions ##########################################################
 
write-host "$(Get-Date -format 'u') # Script is running."
 
$dateGenerated = get-date -Format "dd/MM/yyyy HH:mm:ss"
$currentDirectory = Get-Location
 
# Set default report file name if one hasn't been provided as parameter
If([string]::IsNullOrEmpty($ReportFileName))
{
    $ReportFileName = $currentDirectory.ToString()+"\"+$TaskSequenceID+".html"
}
 
# Get list of all DPs if none specified
If([string]::IsNullOrEmpty($DistributionPoints))
{
    write-host "$(Get-Date -format 'u') # Fetching the list of Distribution Points..."
    $DistributionPoints = Get-DistributionPointsList
}
else
{
    write-host "$(Get-Date -format 'u') # Using user-supplied list of Distribution Points"
}
 
# Get status of content
$aContentStatusResults = Get-TaskSequenceContentStatus -TaskSequenceID $TaskSequenceID -DistributionPoints $DistributionPoints
 
write-host "$(Get-Date -format 'u') # Starting to process the results..."
 
# Convert the result array to hashtable for ease of processing
$hashContentInfo = $aContentStatusResults | group PackageID -AsHashTable
 
######################################
#        Generate HTML report        #
######################################
 
# Build HTML content
$htmlContentStatusTable = "
<table>
<caption>Content information</caption>
<tr>
<th>Package ID</th>
<th>Package Name</th>
<th>Package type</th>
<th>Total</th>
<th>Success</th>
<th>In progress</th>
<th>Failed</th>
<th>Unknown</th>
<th>Not targeted</th>
"
ForEach($DP in $DistributionPoints)
{
    $htmlContentStatusTable += "
<th>$DP</th>
"
}
 
$htmlContentStatusTable += "</tr>
"
 
# Go through all unique package IDs
ForEach($key in $hashContentInfo.Keys)
{
 
    $iTotal = 0
    $iSuccess = 0
    $iInProgress = 0
    $iFailed = 0
    $iUnknown = 0
    $iNotTargeted = 0
 
    # Count statuses of each package across all of DPs
    foreach($PackageInfo in $hashContentInfo[$key])
    {
        $iTotal++
        If($PackageInfo.Status -eq "Success") {$iSuccess++}
        If($PackageInfo.Status -eq "In Progress") {$iInProgress++}
        If($PackageInfo.Status -eq "Unknown") {$iUnknown}
        If($PackageInfo.Status -eq "Failed") {$iFailed++}
        If($PackageInfo.Status -eq "Not targeted") {$iNotTargeted++}
    }
 
    $htmlContentStatusTable += "
<tr>
<td>"+$PackageInfo.PackageID+"</td>
<td>"+$PackageInfo.Name+"</td>
<td>"+$PackageInfo.ResourceType+"</td>
<td>"+$iTotal+"</td>
<td>"+$iSuccess+"</td>
"
 
    # Set cell bacground color depending on the status
    $inprogressbgcolor = "#FFFFFF"
    $unknownbgcolor = "#FFFFFF"
    $failedbgcolor = "#FFFFFF"
    $nottargetedbgcolor = "#FFFFFF"
 
    # Change cell colour only if number of DPs with non-success statuses is greater than 0
    If($iInProgress -gt 0) { $inprogressbgcolor = "#FFFF44" }
    If($iUnknown -gt 0) { $unknownbgcolor = "#CECECE" }
    If($iFailed -gt 0) { $failedbgcolor = "#FF0000" }
 
    $htmlContentStatusTable += "
<td bgcolor="+$inprogressbgcolor+">"+$iInProgress+"</td>
<td bgcolor="+$failedbgcolor+">"+$iFailed+"</td>
<td bgcolor="+$unknownbgcolor+">"+$iUnknown+"</td>
<td>"+$iNotTargeted+"</td>
"
 
    # List every package status against every DP, including appropriate colour coding
    foreach($PackageInfo in $hashContentInfo[$key])
    {
        # Set cell bacground color depending on the status
        $bgcolor = "#FFFFFF"
        If($PackageInfo.Status -eq "Success") { $bgcolor = "#44FF44" }
        If($PackageInfo.Status -eq "In Progress") { $bgcolor = "#FFFF44" }
        If($PackageInfo.Status -eq "Unknown") { $bgcolor = "#CECECE" }
        If($PackageInfo.Status -eq "Failed") { $bgcolor = "#FF0000" }
        If($PackageInfo.Status -eq "Not targeted") { $bgcolor = "#8C8C8C" }
 
        $htmlContentStatusTable += "
<td bgcolor="+$bgcolor+">"+$PackageInfo.Message+"</td>
"
    }
 
    $htmlContentStatusTable += "</tr>
`r`n"
}
 
$htmlContentStatusTable += "</table>
"
 
# Get Task Sequence properties
$TaskSequenceInfo = Get-CMTaskSequence -TaskSequencePackageId $TaskSequenceID
 
# Generate table with Task Sequence properties
$htmlTSTable = "
<table>
<caption>General information</caption>
 
`r`n"
$htmlTSTable += "
<tr>
<th>Property</th>
<th>Value</th>
</tr>
`r`n"
$htmlTSTable += "
<tr>
<td>Task Sequence ID</td>
<td>"+$TaskSequenceInfo.PackageID+"</td>
</tr>
`r`n"
$htmlTSTable += "
<tr>
<td>Task Sequence name</td>
<td>"+$TaskSequenceInfo.Name+"</td>
</tr>
`r`n"
$htmlTSTable += "
<tr>
<td>Task Sequence description</td>
<td>"+$TaskSequenceInfo.Description+"</td>
</tr>
`r`n"
$htmlTSTable += "
<tr>
<td>Task Sequence version</td>
<td>"+$TaskSequenceInfo.Version+"</td>
</tr>
`r`n"
$htmlTSTable += "
<tr>
<td>Task Sequence creation date</td>
<td>"+$TaskSequenceInfo.SourceDate+"</td>
</tr>
`r`n"
$htmlTSTable += "
<tr>
<td>Task Sequence edited date</td>
<td>"+$TaskSequenceInfo.LastRefreshTime+"</td>
</tr>
`r`n"
$htmlTSTable += "
<tr>
<td>Boot image ID</td>
<td>"+$TaskSequenceInfo.BootImageID+"</td>
</tr>
`r`n"
$htmlTSTable += "
<tr>
<td>Date generated</td>
<td>"+$dateGenerated+"</td>
</tr>
`r`n"
$htmlTSTable += "</table>
`r`n"
 
# Define style via CSS
$style = @'
<style type="text/css">
table {
    border: 1px solid #000000;
    border-collapse: collapse;
}
td {
    font-family: calibri, verdana, arial, helvetica, sans-serif;
    border: 1px solid #000000;
    white-space: nowrap;
}
body {
    font-family: calibri, verdana, arial, helvetica, sans-serif;
    font-size:10pt;
}
th {
    font-family: calibri, verdana, arial, helvetica, sans-serif;
    background-color:black;
    color:white;
    font-weight: bold;
    white-space: nowrap;
}
</style>
 
'@
 
write-host "$(Get-Date -format 'u') # Writing the report to " $ReportFileName
 
# Write the results into HTML file
ConvertTo-Html -Head "<title>Content report for $TaskSequenceID</title>$style" -Body "$htmlTSTable
 
$htmlContentStatusTable"| out-file $ReportFileName
 
# Return to the start location
Set-Location $currentDirectory
 
write-host "$(Get-Date -format 'u') # Script finished."