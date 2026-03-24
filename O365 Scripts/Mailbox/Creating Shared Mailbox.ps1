# Define shared mailbox details
$SharedMailbox = "shared@yourdomain.com"
$DisplayName = "Shared Mailbox"

# Create the shared mailbox
New-Mailbox -Shared -Name $DisplayName -PrimarySmtpAddress $SharedMailbox

# Assign permissions to users
Add-MailboxPermission -Identity $SharedMailbox -User "user@yourdomain.com" -AccessRights FullAccess -InheritanceType All
