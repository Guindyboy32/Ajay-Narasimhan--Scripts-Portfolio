Exchange Management (OnPrem- Hybrid Env)

This folder contains PowerShell scripts designed to automate common Exchange Online and Exchange On‑Premises administrative tasks. These scripts streamline mailbox management, permissions, remote mailbox creation, and other day‑to‑day Exchange operations.
These tools are intended for administrators who already have a basic understanding of Exchange, ECP, and PowerShell. If you're new to Exchange administration, consider reviewing Microsoft’s Exchange documentation or introductory courses before running these scripts in production.

Purpose
The scripts in this directory help automate tasks such as:
- Managing mailbox permissions
- Converting mailboxes to shared
- Creating remote mailboxes
- Granting Send As permissions
- Managing calendar access
- Configuring forwarding
- Connecting to the Exchange Management Shell

Script Index

Mailbox & Permission Management
- Adding Calendar Permissions.ps1

Grants calendar access to users or groups.
- Remove Calendar Permissions.ps1

Removes existing calendar permissions.
- Granting Send AS.ps1

Assigns Send As permissions to a mailbox.
- Forwarding Email Address.ps1
Configures mailbox forwarding to another recipient.

- Converting to Shared Mailbox.ps1
Converts a user mailbox into a shared mailbox.


- Exchange Shell Remote Mailbox Creation with UI.ps1
Provides a UI‑based workflow for creating remote mailboxes in a hybrid environment.

 - Connecting to ECP Shell.ps1
Script for connecting to the Exchange Management Shell (on‑prem or hybrid).


- Removing Calendar Permissions.ps1
Removes calendar access for specified users.

Notes
- Always test scripts in a non‑production environment first.
- Some scripts modify mailbox permissions—review carefully before running.
- Ensure you have the correct RBAC roles assigned.
- Update variables inside each script (mailbox, user, permissions) before execution.



 
