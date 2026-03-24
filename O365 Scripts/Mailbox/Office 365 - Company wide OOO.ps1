# Define out of office message
$Subject = "Out of Office"
$Message = "Thank you for your email. I am currently out of the office and will get back to you as soon as possible."

# Get all users
$Users = Get-MsolUser -All

# Set out of office message for each user
foreach ($User in $Users) {
    Set-MailboxAutoReplyConfiguration -Identity $User.UserPrincipalName -AutoReplyState Enabled -InternalMessage $Message -ExternalMessage $Message -Subject $Subject
}
