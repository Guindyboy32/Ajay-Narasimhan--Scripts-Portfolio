This document outlines the standardized offboarding process for users in TestDomain, including mailbox configuration, forwarding, delegation, license removal, and final validation.
All steps use PowerShell and apply to Exchange Online Hybrid or Exchange On‑Prem with M365.

1. Configure Automatic Replies (Out of Office)
Enable automatic replies to notify internal and external senders that the user is no longer with the organization.
Set-MailboxAutoReplyConfiguration -Identity "<UserUPN>" `
    -AutoReplyState Enabled `
    -InternalMessage "This user is no longer with TestDomain. Please contact <ContactName> at <ContactEmail>." `
    -ExternalMessage "This user is no longer with TestDomain. Please contact <ContactName> at <ContactEmail>."



2. Enable Email Forwarding to Manager
Forward all new incoming mail to the user’s manager or designated successor.
Set -DeliverToMailboxAndForward $true to keep a copy in the mailbox.
Set-Mailbox -Identity "<UserUPN>" `
    -ForwardingSMTPAddress "<ManagerEmail>" `
    -DeliverToMailboxAndForward $true



3. Grant Mailbox Delegation
Provide Full Access permissions to HR, the manager, or another authorized reviewer.
Add-MailboxPermission -Identity "<UserUPN>" `
    -User "<DelegateEmail>" `
    -AccessRights FullAccess `
    -InheritanceType All `
    -AutoMapping $true



4. Convert User Mailbox to Shared
Convert the mailbox to a shared mailbox to retain access without requiring an active license.
Set-Mailbox -Identity "<UserUPN>" -Type Shared

Note:
Allow 5–10 minutes before removing the license.
Shared mailboxes must remain under 50 GB to stay license‑free.

5. Remove Microsoft 365 License
After confirming the mailbox is shared, remove the assigned license.
Set-MsolUserLicense -UserPrincipalName "<UserUPN>" `
    -RemoveLicenses "TestDomain:ENTERPRISEPACK"

6.Validate Final Configuration
Run the following commands to confirm forwarding, permissions, mailbox type, and license status.
✔ Mailbox type & forwarding
Get-Mailbox -Identity "<UserUPN>" |
    Select DisplayName, RecipientTypeDetails, ForwardingSMTPAddress

Delegated access
Get-MailboxPermission -Identity "<UserUPN>" |
    Where-Object { $_.AccessRights -contains "FullAccess" }


License status
Get-MsolUser -UserPrincipalName "<UserUPN>" |
    Select DisplayName, Licenses


Summary
This offboarding workflow ensures:
- Automatic replies are enabled
- Mail forwarding is configured
- Delegation is granted
- The mailbox is converted to shared
- Licenses are reclaimed
- All configurations are validated

This process maintains continuity, preserves data, and ensures compliance with TestDomain offboarding standards.
