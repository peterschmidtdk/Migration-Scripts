<#
.SYNOPSIS
    Bulk Create Shared Mailboxes in Exchange Online from a CSV file.

.DESCRIPTION
    This script reads a CSV file containing shared mailbox details and creates them in Exchange Online.
    It also assigns Full Access and Send As permissions based on the CSV data (if provided).
    All operations are logged to a file for tracking.

.VERSION
    1.2 - Added logging functionality.

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
$ScriptVersion = "1.2"

# Define Log File Path
$LogFile = ".\SharedMailboxCreation.log"

# Function to Write Log Entries
function Write-Log {
    param (
        [string]$Message,
        [string]$LogType = "INFO"
    )
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "$TimeStamp [$LogType] $Message"
    Add-Content -Path $LogFile -Value $LogEntry
    Write-Host $LogEntry
}

# Start Logging
Write-Log "Starting Bulk Shared Mailbox Creation Script - Version $ScriptVersion"

# Connect to Exchange Online
try {
    Connect-ExchangeOnline -UserPrincipalName admin@yourdomain.com
    Write-Log "Successfully connected to Exchange Online."
} catch {
    Write-Log "Error connecting to Exchange Online: $_" -LogType "ERROR"
    Exit
}

# Define CSV File Path
$CsvFilePath = ".\SharedMailboxes.csv"

# Check if CSV file exists
if (-Not (Test-Path $CsvFilePath)) {
    Write-Log "Error: CSV file not found at $CsvFilePath" -LogType "ERROR"
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
    try {
        Write-Host "Creating shared mailbox: $DisplayName ($PrimarySmtpAddress)"
        New-Mailbox -Shared -Name $DisplayName -Alias $Alias -PrimarySmtpAddress $PrimarySmtpAddress
        Write-Log "Successfully created shared mailbox: $DisplayName ($PrimarySmtpAddress)"
    } catch {
        Write-Log "Error creating shared mailbox: $DisplayName ($PrimarySmtpAddress) - $_" -LogType "ERROR"
        continue
    }

    # Assign Send As Permissions (Only if values exist)
    if ($GrantSendAs.Count -gt 0 -and $GrantSendAs[0] -ne "") {
        foreach ($User in $GrantSendAs) {
            try {
                Write-Host "Granting 'Send As' permission to: $User"
                Add-RecipientPermission -Identity $PrimarySmtpAddress -Trustee $User -AccessRights SendAs -Confirm:$false
                Write-Log "Granted 'Send As' permission to $User for $PrimarySmtpAddress"
            } catch {
                Write-Log "Error granting 'Send As' permission to $User for $PrimarySmtpAddress - $_" -LogType "ERROR"
            }
        }
    } else {
        Write-Log "Skipping 'Send As' permissions for $DisplayName (No users specified)"
    }

    # Assign Full Access Permissions (Only if values exist)
    if ($GrantFullAccess.Count -gt 0 -and $GrantFullAccess[0] -ne "") {
        foreach ($User in $GrantFullAccess) {
            try {
                Write-Host "Granting 'Full Access' permission to: $User"
                Add-MailboxPermission -Identity $PrimarySmtpAddress -User $User -AccessRights FullAccess -InheritanceType All -Confirm:$false
                Write-Log "Granted 'Full Access' permission to $User for $PrimarySmtpAddress"
            } catch {
                Write-Log "Error granting 'Full Access' permission to $User for $PrimarySmtpAddress - $_" -LogType "ERROR"
            }
        }
    } else {
        Write-Log "Skipping 'Full Access' permissions for $DisplayName (No users specified)"
    }
}

# Disconnect from Exchange Online
try {
    Disconnect-ExchangeOnline -Confirm:$false
    Write-Log "Successfully disconnected from Exchange Online."
} catch {
    Write-Log "Error disconnecting from Exchange Online: $_" -LogType "ERROR"
}

Write-Log "Bulk shared mailbox creation completed. Script Version: $ScriptVersion"
