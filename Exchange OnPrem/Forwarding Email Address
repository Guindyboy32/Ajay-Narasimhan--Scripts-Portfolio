$terminatedUser = "terminated.user@example.com"
$managerUser = "manager@example.com"
# Forward all incoming emails to the manager
Set-Mailbox $terminatedUser -ForwardingAddress $managerUser -DeliverToMailboxAndForward $false
Write-Output "Email forwarding set for $terminatedUser to $managerUser."


### Forwarding email address - With a copy of the mail in the inbox#

$terminatedUser = "Ajay.Vijayl@TestDomain.com"
$managerUser = "AjayRex@iTestDomain.com"
# Forward all incoming emails to the manager
Set-Mailbox "Ajay.Vijayl@TestDomain.com" -ForwardingAddress "AjayRex@iTestDomain.com" -DeliverToMailboxAndForward $True


Get-Mailbox -Identity "Ajay.Vijayl@TestDomain.com" | Select-Object ForwardingAddress, ForwardingSmtpAddress, DeliverToMailboxAndForward
