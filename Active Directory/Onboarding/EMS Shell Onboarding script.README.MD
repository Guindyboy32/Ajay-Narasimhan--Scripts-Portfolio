Overview
This PowerShell script automates the end‑to‑end provisioning process for new hires in a Hybrid Active Directory + Exchange Online environment. It is designed for use in the Exchange Management Shell (EMS) and supports semi‑interactive confirmations at each major step.

The script handles:
- Creating on‑prem AD accounts using a template user
- Applying extension attributes
- Setting title, department, and address
- Assigning the correct manager
- Setting office location
- Creating a remote mailbox for Exchange Online
- Applying SMTP policies
- Displaying mailbox validation details
This workflow is ideal for environments where HR provides a CSV of new hires and IT provisions accounts manually but with automation assistance.

Key Features

Hybrid‑Ready
Uses on‑prem AD cmdlets and on‑prem Exchange cmdlets to provision remote mailboxes that sync to Exchange Online.

Semi‑Interactive
Prompts for confirmation at each major step to ensure accuracy and control.

Template‑Based User Creation
Inherits attributes from predefined AD template accounts.

Manager Lookup by EmployeeID
Automatically assigns the correct manager if found in AD.

SMTP Policy Handling
Automatically retries mailbox provisioning if email address policies conflict.

Mailbox Validation
Displays final mailbox details for verification.

Requirements
Must be run in:
- Exchange Management Shell (EMS)
This ensures both AD and Exchange cmdlets are available.

Environment Requirements
- On‑prem Active Directory
- On‑prem Exchange Server configured for Hybrid
- Azure AD Connect syncing the target OU
- Template users present in AD
- Remote routing domain configured (e.g., tenant.mail.onmicrosoft.com)

CSV Format
The script expects a CSV file with the following headers:
samAccountName
FirstName
LastName
FullNameCaps
ManagerID
DeptSRVPName
DeptSRVPID
EmployeeLevel
StartDate
VPID
VPName
EmployeeType
Title
Department
StreetAddress
Template


Example Row
jdoe,John,Doe,JOHN DOE,12345,Jane Smith,67890,3,2024-01-15,4455,Mark Lee,FullTime,Analyst,Finance,"123 Market St",TestSiteTemplate


How to Use
- Place your CSV at:
C:\NewHires.csv
- Open Exchange Management Shell.
- Run the script:
.\NewHire-Provisioning.ps1
- Follow the on‑screen prompts:
- Enter temporary passwords
- Confirm template selection
- Approve AD user creation
- Approve attribute stamping
- Approve mailbox creation
- Review mailbox validation
Each user is processed one at a time with clear checkpoints.

What the Script Does (Step‑By‑Step)
1. Load CSV
Reads all new hires and displays the count.

2. Prompt for Password
SecureString input for each new hire.

3. Select Template
Validates template names and loads the template user.

4. Create AD User
Creates the account in the correct OU using inherited attributes.

5. Apply Extension Attributes
Stamps HR‑provided metadata.

6. Apply Title, Department, Address
Updates core identity fields.

7. Assign Manager
Looks up manager by employeeID.

8. Set Office Location
Sets physicalDeliveryOfficeName to “offsite”.

9. Create Remote Mailbox
Creates the mailbox object on‑prem for Exchange Online.

10. Apply SMTP Address
Handles policy conflicts automatically.

11. Validate Mailbox
Displays primary SMTP and email addresses.

Notes
- The script is intentionally semi‑interactive to prevent accidental provisioning errors.
- All Exchange mailbox operations occur on‑prem, then sync to the cloud.
- If a manager cannot be found, the script safely skips that step.

Author
Ajay Narasimhan

