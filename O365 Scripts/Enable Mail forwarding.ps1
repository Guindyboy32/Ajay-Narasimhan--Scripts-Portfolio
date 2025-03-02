# Define user details
$Mailbox = "user@yourdomain.com"
$ForwardingAddress = "forwardto@yourdomain.com"

# Enable and set mailbox forwarding
Set-Mailbox -Identity $Mailbox -ForwardingAddress $ForwardingAddress -DeliverToMailboxAndForward $true
