This repository contains PowerShell scripts designed to help automate common Microsoft 365 (O365) administrative tasks. These scripts streamline work across Exchange Online, SharePoint Online, and Microsoft Teams by providing reusable code snippets and examples.

The scripts in this repo are intended to:
- Automate repetitive O365 admin tasks
- Improve consistency and reduce manual effort
- Provide ready‑to‑use templates for Exchange, SharePoint, and Teams automation
- Serve as a reference for connecting to Microsoft 365 services using PowerShell
Before running any script, ensure you have the required modules installed and that you authenticate to the appropriate service.

Connecting to Microsoft 365 Services
Most scripts require an authenticated session with one or more O365 services. Below are the standard connection commands used throughout this repository.
Exchange Online
$UserCredential = Get-Credential
Connect-ExchangeOnline -Credential $UserCredential


SharePoint Online
$UserCredential = Get-Credential
Connect-SPOService -Credential $UserCredential


Microsoft Teams
$UserCredential = Get-Credential
Connect-MicrosoftTeams -Credential $UserCredential




