# Define variables
$MailboxOwner = "owner@example.com"   # The calendar owner
$Delegate = "delegate@example.com"    # The user receiving Editor access
$AccessLevel = "Editor"
# Grant Editor permissions
Add-MailboxFolderPermission -Identity "$MailboxOwner:\Calendar" -User $Delegate -AccessRights $AccessLevel


# Granting access to Private events

Set-MailboxFolderPermission -Identity "$MailboxOwner:\Calendar" -User $Delegate -AccessRights $AccessLevel -SharingPermissionFlags Delegate,CanViewPrivateItems

#Verifying permissions
Get-MailboxFolderPermission -Identity "Ajay@TestDomain.com:\Calendar"

