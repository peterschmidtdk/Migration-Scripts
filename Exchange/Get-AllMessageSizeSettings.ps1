# Script to check for Message Size settings in Exchange Online

# Show Exchange Online Tenant Message Size Settings
$TransportConfig = Get-TransportConfig
Write-Host "Tenant Transport Config Message Size Settings:"
Write-Host "MaxSendSize: $($TransportConfig.MaxSendSize)"
Write-Host "MaxReceiveSize: $($TransportConfig.MaxReceiveSize)"
Write-Host "--------------------------------------------------"

$MailboxPlanConfig = Get-MailboxPlan
Write-Host "Tenant Mailbox Plan Message Size Settings (will lists for all plans):"
Write-Host "MaxSendSize: "  $($MailboxPlanConfig.MaxSendSize)
Write-Host "MaxReceiveSize: $($MailboxPlanConfig.MaxReceiveSize)"
Write-Host "--------------------------------------------------"

# Fetch Individual Mailbox Message Size Settings and Export to CSV
$mailboxes = Get-Mailbox -ResultSize Unlimited | Select UserPrincipalName,PrimarySmtpAddress,MaxSendSize,MaxReceiveSize

# Specify path for the CSV file
$csvPath = ".\Output-MailboxMessageSizeSettings.csv"

$mailboxes | Export-Csv -Path $csvPath -NoTypeInformation -Encoding Unicode -Delimiter ";"

Write-Host "Mailbox settings have been saved to: $csvPath"


