# This script is based on the script from ShareGate: https://documentation.sharegate.com/hc/en-us/articles/115000731827
# Script is used to map users from a CSV file (SourceValue,DestinationValue) UPNs on both sides to a ShareGate User Mapping file (.sgum)

Import-Module Sharegate
$csvFile = ".\UserCSVfile.csv"
$table = Import-CSV $csvFile -Delimiter ","
$mappingSettings = New-MappingSettings
foreach ($row in $table) {
    $results = Set-UserAndGroupMapping -MappingSettings $mappingSettings -Source $row.SourceValue -Destination $row.DestinationValue
    $row.sourcevalue
}
#Make sure the Sub folder exists before export:
Export-UserAndGroupMapping -MappingSettings $mappingSettings -Path ".\FileExport"
