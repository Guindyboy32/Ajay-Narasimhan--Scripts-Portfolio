# Define user details
$UserPrincipalName = "user@yourdomain.com"

# Get mailbox size
Get-MailboxStatistics -Identity $UserPrincipalName | Select-Object DisplayName, TotalItemSize
