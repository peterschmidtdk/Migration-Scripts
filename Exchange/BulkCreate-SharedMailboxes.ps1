<#
.SYNOPSIS
    Bulk Create Shared Mailboxes in Exchange Online from a CSV file.

.DESCRIPTION
    This script reads a CSV file containing shared mailbox details and creates them in Exchange Online.
    It also assigns Full Access and Send As permissions based on the CSV data.

.VERSION
    1.0 - Initial release

.AUTHOR
    Spyro Brzezinsk

.LAST UPDATED
    2025-03-18

.NOTES
    - Requires Exchange Online PowerShell module (EXO V2).
    - Run the script with appropriate administrative privileges.
    - Ensure the CSV file follows the required format.

#>

# Define Script Version
$ScriptVersion = "1.0"

Write-Host "Starting Bulk Shared Mailbox Creation Script - Version $ScriptVersion"

# Connect to Exchange Online
Connect-ExchangeOnline -UserPrincipalName admin@yourdomain.com

# Define CSV File Path
$CsvFilePath = "C:\Path\To\SharedMailboxes.csv"

# Check if CSV file exists
if (-Not (Test-Path $CsvFilePath)) {
    Write-Host "Error: CSV file not found at $CsvFilePath" -ForegroundColor Red
    Exit
}

# Import CSV file
$Mailboxes = Import-Csv $CsvFilePath

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

Write-Host "Bulk shared mailbox creation completed. Script Version: $ScriptVersion"
