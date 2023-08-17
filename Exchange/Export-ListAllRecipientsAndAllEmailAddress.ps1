
# Script to export all E-mail addresses from All Recipients in Exchange Online
# First connect to Exchange Online using Connect-ExchangeOnline

$strFile = ".\Export-AllRecipientsAllEmailAddress.csv"

Get-Recipient -ResultSize Unlimited | Select-Object DisplayName,PrimarySmtpAddress,RecipientTypeDetails, @{Name="EmailAddresses";Expression={($_.EmailAddresses | Where-Object {$_ -clike "smtp*"} | ForEach-Object {$_ -replace "smtp:",""}) -join ","}} | Sort-Object DisplayName | Export-CSV $strFile -NoTypeInformation -Encoding UTF8 -Delimiter ";"