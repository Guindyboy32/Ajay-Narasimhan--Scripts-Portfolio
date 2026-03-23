New Hire Automation Script
This repository contains a PowerShell script designed to automate onboarding for hybrid Active Directory + Exchange Online environments. The script is intended to be run from the Exchange Management Shell (EMS), which provides the necessary cmdlets for remote mailbox creation in hybrid mode.

Overview
This script automates the following tasks for each new hire:
• 	Imports user data from a CSV file
• 	Prompts for a temporary password
• 	Selects a template user
• 	Creates a new AD user based on the template
• 	Applies extension attributes
• 	Sets title, department, and address
• 	Updates the manager attribute
• 	Sets the office/room number
• 	Creates a remote mailbox (hybrid)
• 	Applies SMTP settings with policy handling
• 	Displays mailbox validation details

The script pauses between major steps to allow operator verification.

Environment Requirements
This script is designed for hybrid Exchange environments and should be run from:
Exchange Management Shell (EMS)
EMS provides the required cmdlets such as:

- Enable-RemoteMailbox
- Set-RemoteMailbox
- Get-RemoteMailbox

	Additional Requirements
• 	ActiveDirectory PowerShell module
• 	Permissions to:
• 	Create and modify AD users
• 	Create remote mailboxes
• 	Modify Exchange attributes

CSV Format
Your  file must include the following columns:

Example CSV Row

samAccountName,FirstName,LastName,FullNameCaps,ManagerID,DeptSRVPName,DeptSRVPID,EmployeeLevel,StartDate,VPID,VPName,EmployeeType,Title,Department,StreetAddress,Template
jdoe,John,Doe,JOHN DOE,12345,Jane Smith,67890,3,2024-01-15,54321,Robert Brown,FTE,Engineer,IT,123 Main St,TestSiteTemplate

 How to Run
1. 	Open Exchange Management Shell
2. 	Ensure you are connected to:
• 	Active Directory
• 	Exchange Online (if required for hybrid)
3. 	Place  in the expected location (default: )
4. 	Run the script: .\NewHireAutomation.ps1
5. 	Follow the prompts for each user.

Customization
You may modify:
• 	OU paths
• 	Template names
• 	Domain names
• 	Attribute mappings
• 	Mail routing domains
• 	Pause/confirmation prompts

Why This Script Is Necessary
Onboarding users in a hybrid Active Directory + Exchange Online environment involves a long chain of manual steps across multiple systems. Without automation, administrators must:
- Create the AD user manually
- Copy attributes from a template user
- Populate extension attributes
- Set title, department, and address fields
- Assign the correct manager
- Configure office/room information
- Create a remote mailbox in Exchange hybrid
- Apply SMTP settings and verify mailbox provisioning

This script is provided for educational and demonstration purposes.
It was originally designed for a specific hybrid Active Directory and Exchange environment and will require customization before use in any other environment.
You should review and modify:
- OU paths
- Domain names
- Template user accounts
- Attribute mappings
- Mail routing domains
- Hybrid Exchange configuration

                     before running this script in a production environment.

