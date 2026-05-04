A Windows Forms–based PowerShell tool for safely creating Remote Mailboxes in a Hybrid Exchange environment.
Designed for on‑prem Exchange 2013/2016/2019 environments where users are synced to Microsoft 365 via Azure AD Connect.
This tool provides a technician‑friendly GUI, validates all prerequisites, prevents duplicate mailbox creation, and logs all actions for auditing.

Features
Fully On‑Prem Exchange Compatible
Uses native Exchange Management Shell cmdlets:
- Get-Mailbox
- Enable-RemoteMailbox
- Set-RemoteMailbox
No Exchange Online modules required.

Active Directory Validation
Before creating a mailbox, the tool checks:
- AD user exists
- Mailbox does not already exist
- Exchange Management Shell is loaded

Safe, Idempotent Mailbox Creation
The tool prevents:
- duplicate remote mailboxes
- invalid SMTP assignments
- running without Exchange loaded
- running against non‑existent AD users

 GUI‑Driven Workflow
- Clean WinForms interface
- Status messages with color feedback
- Multi‑line output for SMTP details
- Button lockout during execution

Logging
All actions are logged to:
%USERPROFILE%\RemoteMailboxTool.log

This includes:
- validation steps
- mailbox creation attempts
- errors and warnings
- success confirmations

 How It Works
- Technician enters a samAccountName
- Script validates:
- Exchange connectivity
- AD user existence
- Mailbox existence
- Script builds:
- Primary SMTP address
- Remote routing address
- Script runs:
- Enable-RemoteMailbox
- Set-RemoteMailbox -EmailAddressPolicyEnabled $false
- Set-RemoteMailbox -PrimarySmtpAddress
- Results are displayed in the GUI and logged

Requirements
- Windows Server or Windows 10/11
- Exchange Management Shell (on‑prem)
- Active Directory PowerShell module
- Hybrid Exchange environment
- Azure AD Connect (for syncing to Microsoft 365)

Running the Tool
1. Open Exchange Management Shell
This ensures all Exchange cmdlets are available.

2. Run the script
.\RemoteMailboxCreator.ps1

3. Enter the username
Example:
jdoe


4. Click “Create Remote Mailbox”
The tool handles the rest.

Configuration
At the top of the script, update:
$PrimaryDomain = "yourdomain.com"
$RemoteRoutingDomain = "yourtenant.mail.onmicrosoft.com"


These must match your hybrid Exchange configuration.

Logging
All actions are written to:
%USERPROFILE%\RemoteMailboxTool.log


This includes:
- timestamps
- validation results
- mailbox creation steps
- errors and exceptions
Perfect for auditing and troubleshooting.

Safety & Idempotency
This tool is safe to run multiple times because it:
- checks if the mailbox already exists
- checks if the AD user exists
- checks if Exchange is connected
- stops early on invalid input
- logs all actions
No duplicate mailboxes will ever be created.

Author
Ajay Narasimhan
Senior Systems Engineer
San Francisco, CA
