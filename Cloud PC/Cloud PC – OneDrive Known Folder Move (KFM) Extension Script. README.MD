Cloud PC – OneDrive Known Folder Move (KFM) Extension Script

A PowerShell automation script that extends Microsoft’s Known Folder Move (KFM) capabilities on Windows 365 Cloud PCs and Azure Virtual Desktop. While Microsoft automatically redirects Desktop, Documents, and Pictures when KFM is enabled, this script adds full redirection support for:
- Downloads
- Music
- Videos
It also safely migrates existing content, updates registry paths, and ensures Windows immediately recognizes the new folder locations.

Overview

Cloud PCs rely heavily on OneDrive for roaming user data. However, Microsoft’s built‑in KFM only covers three folders. This script completes the experience by redirecting additional user folders into OneDrive, ensuring:
- Consistent user experience across Cloud PCs
- Reduced local disk usage
- Improved data resilience and backup
- Seamless roaming across sessions
- Enterprise‑grade folder standardization

This script is designed for Intune, AVD, Windows 365, and enterprise environments where user data portability is essential.

 Automatic OneDrive Detection
- Reads OneDrive Business path from registry
- Waits for OneDrive to initialize if needed
- Exits safely if OneDrive is unavailable

 Safe Content Migration
- Moves existing files from local folders to OneDrive
- Creates missing OneDrive folders
- Skips gracefully if folders are empty or missing
 
 Registry Redirection
Updates:
HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders


to permanently redirect the folder paths.

Explorer Refresh
Restarts Explorer to ensure Windows immediately recognizes the new folder locations.

Robust Error Handling
- Try/catch blocks
- Color‑coded logging
- Non‑fatal warnings
- Safe to run multiple times (idempotent)

 Why This Script Exists
Microsoft’s Known Folder Move is intentionally limited to three folders. In Cloud PC environments, Downloads is often the largest source of local disk usage — and the most commonly lost data when users switch devices.
This script solves that problem by extending KFM to all major user folders.


Use Cases
- Windows 365 Cloud PC onboarding
- Azure Virtual Desktop user profile standardization
- Enterprise OneDrive rollout
- Reducing Cloud PC storage consumption
- Ensuring user data is always backed up
- Creating a roaming, persistent user experience

How It Works
- Detects OneDrive Business folder from registry
- Validates OneDrive readiness
- Defines extended KFM folder map
- Creates missing OneDrive folders
- Migrates existing user content
- Updates registry redirection keys
- Restarts Explorer to apply changes

Script
The full script is included in this repository under:
/Scripts/OneDrive-KFM-Extended.ps1


It is fully documented with:
- Function‑level comments
- Error handling
- Logging
- Clear structure

Deployment Options
This script can be deployed via:
- Intune Win32 App
- Intune PowerShell Script
- GPO Logon Script
- AVD FSLogix profile container startup
- Manual execution for testing

