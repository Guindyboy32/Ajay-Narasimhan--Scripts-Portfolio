Overview
This PowerShell script automates adding users to Microsoft Teams and their associated private channels using a CSV file. It is designed for administrators who need to onboard users into Teams at scale while ensuring correct access to private channels.

The script:
- Connects to Microsoft Teams
- Reads user/team/channel assignments from a CSV
- Adds users to the team (if not already a member)
- Adds users to specified private channels
- Provides clear console output for each action
This is ideal for onboarding, department moves, or bulk access corrections.

CSV Format
Your CSV file must contain the following columns:
UserUPN             TeamName         PrivateChannels
user@domain.com     Marketing Team    Leadership;Budget;Planning
                          
Column Details
- UserUPN – The user’s UPN (email address).
- TeamName – The display name of the Microsoft Team.
- PrivateChannels – Semicolon‑separated list of private channel names.

How to Run
- Install the Microsoft Teams PowerShell module (if not already installed):
Install-Module MicrosoftTeams

- Connect to Teams:
Connect-MicrosoftTeams


- Run the script:
.\Add-TeamUsers.ps1


Make sure the CSV path inside the script matches your environment:
$rows = Import-Csv "C:\Scripts\TeamUsers.csv"



Script Logic Summary
 Connect to Microsoft Teams
                                                 
The script uses Connect-MicrosoftTeams to authenticate.
                                                 
Load CSV
Each row defines:
- A user
- A team
- A list of private channels
                                                 
Add user to the team
If the user is not already a member, the script runs:
Add-TeamUser -GroupId <ID> -User <UPN>


Add user to private channels
For each private channel listed, the script runs:
Add-TeamChannelUser -GroupId <ID> -DisplayName <Channel> -User <UPN>


Output
The script prints:
- Missing teams
- Missing private channels
- Users added to teams
- Users added to private channels
- Completion message

Requirements
- Microsoft Teams PowerShell module
- Teams admin permissions
- Permission to manage private channels
- A valid CSV file

Example Output
Adding user1@domain.com to team 'Marketing Team'...
Adding user1@domain.com to private channel 'Leadership'...
Adding user1@domain.com to private channel 'Budget'...
Private channel 'Planning' not found in team 'Marketing Team'.
Processing complete.




