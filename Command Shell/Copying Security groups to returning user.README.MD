Copy AD Group Membership From Template User

This repository contains a Windows batch script that copies all Active Directory group memberships from a *template user* to a *new hire* user. This is useful in environments where new employees need to inherit the same permissions, access, and security groups as an existing role-based template account.

The script uses native Windows Server tools (`dsquery`, `dsget`, `dsmod`) and does not require PowerShell or external modules.

--- Overview

The script performs the following actions:

1. Prompts for the **template user** (source account)
2. Prompts for the **new hire user** (target account)
3. Looks up the **Distinguished Name (DN)** of the new hire
4. Retrieves all AD groups the template user is a member of
5. Iterates through each group and adds the new hire to it
6. Displays return codes for each group modification

This provides a fast, repeatable way to clone group memberships during onboarding.

--- Features

- Copies **all** AD group memberships from one user to another  
- Uses built‑in AD command‑line tools  
- Shows each group being processed  
- Displays success/error codes for troubleshooting  
- Safe to run multiple times  
- Ideal for onboarding workflows and role‑based access setups  

--- Requirements

To run this script, you need:

- A domain‑joined Windows machine  
- RSAT or AD DS tools installed  
- Permissions to modify group membership  
- Access to `dsquery`, `dsget`, and `dsmod`  


These tools are included with:

- Windows Server (Domain Controllers)  
- Windows 10/11 with RSAT installed  

