# Define user details
$UserPrincipalName = "user@yourdomain.com"

# Get sign-in logs for the user
Get-AzureADAuditSignInLogs -Filter "userPrincipalName eq '$UserPrincipalName'" | Select-Object UserPrincipalName, AppDisplayName, CreatedDateTime, IPAddress, Status | Export-Csv -Path "C:\Users\YourUsername\Documents\SignInLogs.csv" -NoTypeInformation
