# Define the mailbox and user
$Mailbox = "MailboxName"   # Replace with the mailbox's identity (e.g., alias, email address, or user name)
$User = "UserName"         # Replace with the user who needs Send As permissions
# Grant Send As permissions
Add-ADPermission -Identity $Mailbox -User $User -AccessRights ExtendedRight -ExtendedRights "Send As"
# Verify the permissions
Get-ADPermission -Identity $Mailbox | Where-Object { $_.User -like $User -and $_.ExtendedRights -contains "Send As" }
