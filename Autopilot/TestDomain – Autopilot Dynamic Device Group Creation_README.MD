Dynamic Membership Rule
Devices are automatically added when their Autopilot registration includes the Group Tag: TestDomainKiosk_Autopilot_AAD

Membership rule logic:
(device.devicePhysicalIds -any (_ -eq "GroupTag:TestDomainKiosk_Autopilot_AAD"))
This ensures devices join the group immediately during Autopilot enrollment.




Windows Autopilot supports assigning devices to groups based on the Group Tag value defined during device registration. This repository provides a structured PowerShell script that:
- Connects to Microsoft Graph
- Creates a Security Group
- Enables Dynamic Membership
- Applies a GroupTag-based membership rule
Any device registered with the matching Group Tag will automatically join the group during Autopilot enrollment.


 Features
- Creates a SecurityEnabled group (required for device targeting)
- Enables DynamicMembership
- Uses a GroupTag-based membership rule
- Clean, structured, variable‑driven design
- Supports Windows Autopilot workflows
- Ideal for kiosk and shared device deployments


Install-Module Microsoft.Graph -Scope CurrentUser

1. Connect to Microsoft Graph
Connect-MgGraph -Scopes "Group.ReadWrite.All"
Select-MgProfile -Name beta

2. Run the script
.\Create-DynamicGroup.ps1


3. Assign the Group Tag to Autopilot devices
TestDomainKiosk_Autopilot_AAD


Devices will automatically join the group during Autopilot enrollment.








