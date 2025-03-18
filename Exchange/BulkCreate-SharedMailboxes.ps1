# Connect to Exchange Online
Connect-ExchangeOnline -UserPrincipalName admin@yourdomain.com

# Import CSV file
$Mailboxes = Import-Csv "C:\Path\To\SharedMailboxes.csv"

foreach ($Mailbox in $Mailboxes) {
    $DisplayName = $Mailbox.DisplayName
    $Alias = $Mailbox.Alias
    $PrimarySmtpAddress = $Mailbox.PrimarySmtpAddress
    $GrantSendAs = $Mailbox.GrantSendAs -split ";"  # Split multiple values if present
    $GrantFullAccess = $Mailbox.GrantFullAccess -split ";"  # Split multiple values if present

    # Create the shared mailbox
    Write-Host "Creating shared mailbox: $DisplayName ($PrimarySmtpAddress)"
    New-Mailbox -Shared -Name $DisplayName -Alias $Alias -PrimarySmtpAddress $PrimarySmtpAddress

    # Assign Send As Permissions
    foreach ($User in $GrantSendAs) {
        if ($User -ne "") {
            Write-Host "Granting 'Send As' permission to: $User"
            Add-RecipientPermission -Identity $PrimarySmtpAddress -Trustee $User -AccessRights SendAs -Confirm:$false
        }
    }

    # Assign Full Access Permissions
    foreach ($User in $GrantFullAccess) {
        if ($User -ne "") {
            Write-Host "Granting 'Full Access' permission to: $User"
            Add-MailboxPermission -Identity $PrimarySmtpAddress -User $User -AccessRights FullAccess -InheritanceType All -Confirm:$false
        }
    }
}

# Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false

Write-Host "Bulk shared mailbox creation completed."