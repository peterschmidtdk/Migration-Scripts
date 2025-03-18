<#
.SYNOPSIS
    Bulk Create Shared Mailboxes in Exchange Online from a CSV file.

.DESCRIPTION
    This script reads a CSV file containing shared mailbox details and creates them in Exchange Online.
    It also assigns Full Access and Send As permissions based on the CSV data (if provided).

.VERSION
    1.1 - Improved error handling and skips empty permissions.

.AUTHOR
    Peter Schmidt

.LAST UPDATED
    2025-03-18

.NOTES
    - Requires Exchange Online PowerShell module (EXO V2).
    - Run the script with appropriate administrative privileges.
    - Ensure the CSV file follows the required format.

#>

# Define Script Version
$ScriptVersion = "1.1"

Write-Host "Starting Bulk Shared Mailbox Creation Script - Version $ScriptVersion"

# Connect to Exchange Online
Connect-ExchangeOnline -UserPrincipalName admin@yourdomain.com

# Define CSV File Path
$CsvFilePath = ".\SharedMailboxes.csv"

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
    $GrantSendAs = if ($Mailbox.PSObject.Properties.Name -contains "GrantSendAs") { $Mailbox.GrantSendAs -split ";" } else { @() }
    $GrantFullAccess = if ($Mailbox.PSObject.Properties.Name -contains "GrantFullAccess") { $Mailbox.GrantFullAccess -split ";" } else { @() }

    # Create the shared mailbox
    Write-Host "Creating shared mailbox: $DisplayName ($PrimarySmtpAddress)"
    New-Mailbox -Shared -Name $DisplayName -Alias $Alias -PrimarySmtpAddress $PrimarySmtpAddress

    # Assign Send As Permissions (Only if values exist)
    if ($GrantSendAs.Count -gt 0 -and $GrantSendAs[0] -ne "") {
        foreach ($User in $GrantSendAs) {
            Write-Host "Granting 'Send As' permission to: $User"
            Add-RecipientPermission -Identity $PrimarySmtpAddress -Trustee $User -AccessRights SendAs -Confirm:$false
        }
    } else {
        Write-Host "Skipping 'Send As' permissions for $DisplayName (No users specified)"
    }

    # Assign Full Access Permissions (Only if values exist)
    if ($GrantFullAccess.Count -gt 0 -and $GrantFullAccess[0] -ne "") {
        foreach ($User in $GrantFullAccess) {
            Write-Host "Granting 'Full Access' permission to: $User"
            Add-MailboxPermission -Identity $PrimarySmtpAddress -User $User -AccessRights FullAccess -InheritanceType All -Confirm:$false
        }
    } else {
        Write-Host "Skipping 'Full Access' permissions for $DisplayName (No users specified)"
    }
}

# Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false

Write-Host "Bulk shared mailbox creation completed. Script Version: $ScriptVersion"
