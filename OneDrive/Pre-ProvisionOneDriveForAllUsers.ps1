#Modified script from the original MS script: https://learn.microsoft.com/en-us/sharepoint/pre-provision-accounts



#Connect to MSOL
Connect-MsolService 
#Connect to SPO - remember to change the URL:
Connect-SPOService -Url https://contoso-admin.sharepoint.com

$list = @()
#Counters
$i = 0


#Get licensed users
$users = Get-MsolUser -All | Where-Object { $_.islicensed -eq $true }

#Total licensed users
$count = $users.count

foreach ($u in $users) {
    $i++
    Write-Host "$i/$count"

    $upn = $u.userprincipalname
    $list += $upn

    if ($i -eq 199) {
        #We reached the limit
        Request-SPOPersonalSite -UserEmails $list -NoWait
        Start-Sleep -Milliseconds 655
        $list = @()
        $i = 0
    }
}

if ($i -gt 0) {
    Request-SPOPersonalSite -UserEmails $list -NoWait
}