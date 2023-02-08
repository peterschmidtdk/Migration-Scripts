<#
.SYNOPSIS
  List all SharePoint Online sites and show Locked state
.DESCRIPTION
  List all SharePoint Online sites and show Locked state
  Tested with SharePoint Online
.OUTPUTS
  Exports all SharePoint site lock state to defined CSV file
.NOTES
  Author:  Peter Schmidt (https://msdigest.net)
.VERSION
  Version: 1.0  2023.02.07  Initial version
#>

#Variables for Admin Center and Site Collection URL
$AdminCenterURL = "https://contoso-admin.sharepoint.com"

#Connect to SharePoint Online using PnPOnline
Connect-PnPOnline -Url $AdminCenterURL -Interactive

#Get a full all sites LockState report
Get-PnPTenantSite | select URL, LockState | Export-Csv .\20230207-SPOLock-Report.csv -NoTypeInformation -Encoding unicode
