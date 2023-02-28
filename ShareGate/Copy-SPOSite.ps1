#Merge Site with Destination Site
Connect-Site -Url "http://myfarm1/sites/mysitecollection" -Browser
$srcSite = Connect-Site -Url "http://myfarm1/sites/mysourcesite"
$dstSite = Connect-Site -Url "http://myfarm1/sites/mydestinationsite"
Copy-Site -Site $srcSite -DestinationSite $dstSite -Merge -Subsites 