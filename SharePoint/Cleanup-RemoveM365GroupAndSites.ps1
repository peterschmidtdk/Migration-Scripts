<#
.SYNOPSIS
  This script can be used to Remove and Delete Microsoft 365 Group and related SPO site.
.DESCRIPTION
  Can be used as part of a cleanup process after a tenant-to-tenant migration.
.OUTPUTS
  
.NOTES
  Author:  Peter Schmidt (https://msdigest.net)
.VERSION
  Version: 1.0  2023.02.11  Initial version
#>

#Variables for Admin Center and Site Collection URL
$AdminCenterURL = "https://contoso-admin.sharepoint.com"

#Connect to SharePoint Online using PnPOnline
Connect-PnPOnline -Url $AdminCenterURL -Interactive
