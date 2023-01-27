<#
.SYNOPSIS
  Small report script to export all items of a SharePoint sites
.DESCRIPTION
  Script exports all items from a defined SharePoint Sites to a CSV file
  Tested with SharePoint Online
.OUTPUTS
  Exports all SharePoint site items to defined CSV file
.NOTES
  Credit/Original   Author: Salaudeen Rajack (https://www.sharepointdiary.com/2019/10/sharepoint-online-site-documents-inventory-report-using-powershell.html)
  Modified Author:  Peter Schmidt (https://msdigest.net)
.VERSION
  Version: 1.0  2023.01.26  Initial slightly modified version, added some export settings 
  Version: 1.1  2023.01.26  Added Checked Out item information

#>
#Start Time
$startTime = "{0:G}" -f (Get-date)
Write-Host "*** Script started on $startTime ***" -f Black -b DarkYellow

#Change the Site URL and CSV Report filename and file location to fit your needs:
$SiteURL = "https://CONTOSO.sharepoint.com/sites/project01"
$CSVReport = ".\CONTOSOS-Site01-SiteInventory.csv"

#Parameters
$Pagesize = 2000

#Function to collect site Inventory
Function Get-PnPSiteInventory
{
[cmdletbinding()]
   param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $Web)
 
    #Skip Apps
    If($Web.url -notlike "$SiteURL*") { return }
    
    Write-host "Getting Site Inventory from Site '$($Web.URL)'" -f Yellow
  
    #Exclude certain libraries
    $ExcludedLists = @("Form Templates", "Preservation Hold Library")
                                
    #Get All Document Libraries from the Web
    $Lists= Get-PnPProperty -ClientObject $Web -Property Lists
    $Lists | Where-Object {$_.BaseType -eq "DocumentLibrary" -and $_.Hidden -eq $false -and $_.Title -notin $ExcludedLists -and $_.ItemCount -gt 0} -PipelineVariable List | ForEach-Object {
        #Get Items from List  
        $global:counter = 0;
        $ListItems = Get-PnPListItem -List $_ -PageSize $Pagesize -Fields Author, Created -ScriptBlock `
                 { Param($items) $global:counter += $items.Count; Write-Progress -PercentComplete ($global:Counter / ($_.ItemCount) * 100) -Activity "Getting Inventory from '$($_.Title)'" -Status "Processing Items $global:Counter to $($_.ItemCount)";}
        Write-Progress -Activity "Completed Retrieving Inventory from Library $($List.Title)" -Completed
      
            #Get Root folder of the List
            $Folder = Get-PnPProperty -ClientObject $_ -Property RootFolder
             
            $SiteInventory = @()
            #Iterate through each Item and collect data          
            ForEach($ListItem in $ListItems)
            { 
                #Collect item data
                $SiteInventory += New-Object PSObject -Property ([ordered]@{
                    SiteName  = $Web.Title
                    SiteURL  = $Web.URL
                    LibraryName = $List.Title
                    ParentFolder = $Folder.ServerRelativeURL
                    FileName = $ListItem.FieldValues.FileLeafRef
                    Type = $ListItem.FileSystemObjectType
                    ItemURL = $ListItem.FieldValues.FileRef
                    CreatedBy = $ListItem.FieldValues.Author.Email
                    CreatedAt = $ListItem.FieldValues.Created
                    ModifiedBy = $ListItem.FieldValues.Editor.Email
                    ModifiedAt = $ListItem.FieldValues.Modified
                    CheckedOutTo = $ListItem.FieldValues.CheckoutUser.LookupValue
                    CheckedOutUserEmail = $ListItem.FieldValues.CheckoutUser.Email

                })
            }
            #Export the result to CSV file
            $SiteInventory | Export-CSV $CSVReport -NoTypeInformation -Append -Delimiter ";" -Encoding Unicode
        }
}
 
#Connect to SharePoint Site collection
Connect-PnPOnline -Url $SiteURL -Interactive
 
#Delete the Output Report, if exists
If (Test-Path $CSVReport) { Remove-Item $CSVReport }   
   
#Call the Function for all Webs
Get-PnPSubWeb -Recurse -IncludeRootWeb | ForEach-Object { Get-PnPSiteInventory $_ }
    
Write-host "Site Inventory Report has been Exported to '$CSVReport'"  -f Green

#End Time
$endTime = "{0:G}" -f (Get-date)
Write-Host "*** Script finished on $endTime ***" -f Black -b DarkYellow
Write-Host "Time elapsed: $(New-Timespan $startTime $endTime)" -f White -b DarkRed
