# Single user
Set-Mailbox -Identity "username" -Type Shared

### Bulk - Uses CSV.
Import-Csv "mailboxes.csv" | ForEach-Object {
    Set-Mailbox -Identity $_.Mailbox -Type Shared
}
