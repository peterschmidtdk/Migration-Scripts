#Variables for Admin Center and Site Collection URL
$AdminCenterURL = "https://contoso-admin.sharepoint.com"

#Connect to SharePoint Online using PnPOnline
Connect-PnPOnline -Url $AdminCenterURL -Interactive

#Get a full all sites LockState report
Get-PnPTenantSite | select URL, LockState | Export-Csv .\20230207-SPOLock-Report.csv -NoTypeInformation -Encoding unicode
