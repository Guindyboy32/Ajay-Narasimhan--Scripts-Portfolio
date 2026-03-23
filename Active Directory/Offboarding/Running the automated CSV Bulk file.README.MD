## Create the CSV in Excel. 

Add the two name columns so we can compose the OOO text per user:

UserId,ManagerEmail,ManagerName,TerminatedName,KeepCopyInMailbox,ConvertToShared,RemoveLicenses
alice@testdomain.local.com,manager1@testdomain.local.com,Jordan Smith,Alice Johnson,TRUE,TRUE,TRUE
bobe@testdomain.local.com,manager2@testdomain.local.com,Alex Kim,Bob Chen,TRUE,TRUE,TRUE
carol@testdomain.local.com,manager3@testdomain.local.com,Emma Davis,Carol Garcia,FALSE,TRUE,TRUE



#If ManagerName or TerminatedName is blank, the scripts auto-resolve from EXO/AD when possible.

#Deploy & run (super short)
#Prereqs (once)

Install-Module ExchangeOnlineManagement -Scope AllUsers
Install-Module Microsoft.Graph -Scope AllUsers
Set-ExecutionPolicy Bypass -Scope Process -Force

#Layout
C:\Offboarding\
  TestDomain-Offboard-FromCsv.ps1
  offboarding.csv
  Evidence\   (auto-created)

Dry run, then live
cd C:\Offboarding

# TestDomain
.\TestDomain-Offboard-FromCsv.ps1 -CsvPath .\offboarding.csv -EvidenceRoot .\Evidence -WhatIf
.\TestDomain-Offboard-FromCsv.ps1 -CsvPath .\offboarding.csv -EvidenceRoot .\Evidence



###
Columns

UserId — user UPN/primary SMTP

ManagerEmail — the delegate who receives forwarding + FullAccess

ManagerName — display name of the manager (optional; auto-resolves if blank)

TerminatedName — display name of the user (optional; auto-resolves if blank)

KeepCopyInMailbox — TRUE/FALSE (keep a copy when forwarding; default TRUE)

ConvertToShared — TRUE/FALSE (optional)

RemoveLicenses — TRUE/FALSE (optional; removes all assigned SKUs)

##
AD offboarding

Disables the user, scrambles password, removes group memberships, hides from GAL, moves to Inactive OU.

Mailbox offboarding

Sets forwarding to manager (keeping a copy if KeepCopyInMailbox=TRUE).

Enables OOO indefinitely with your standard message.

Grants the manager FullAccess + AutoMapping.

✅ If ConvertToShared=TRUE: converts the mailbox to SharedMailbox.

✅ If RemoveLicenses=TRUE: connects to Microsoft Graph and removes all assigned SKUs (E3, E5, etc.).
Once converted to a shared mailbox, no license is required, so this is safe.
