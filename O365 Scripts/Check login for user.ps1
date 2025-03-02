# Define user details
$UserPrincipalName = "user@yourdomain.com"

# Get last logon time
Get-MailboxStatistics -Identity $UserPrincipalName | Select-Object DisplayName, LastLogonTime
