$Mailbox = "ajay1@testdomain.com"  # Mailbox of the person whose calendar you are modifying # Mailbox of the person whose calendar you are modifying
$User = "ajay2@testdomain.com"      # User whose access you want to remove
$Folder = "ajay1@testdomain.com:\Calendar"


# Remove permissions
Remove-MailboxFolderPermission -Identity "ajay1@testdomain.com:\Calendar" -User "ajay2@testdomain.comm" -Confirm:$false
Write-Host "Removed $User's permissions from $Mailbox's calendar."

#Verify
Get-MailboxFolderPermission -Identity "Ajay@TestDomain.com:\Calendar"
