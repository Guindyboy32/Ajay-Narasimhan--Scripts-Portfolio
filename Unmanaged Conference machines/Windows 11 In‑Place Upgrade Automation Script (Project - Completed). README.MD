Status: Completed

Project Overview
This project delivers a fully automated, validated, and supportable method for performing Windows 11 in‑place upgrades using the official Microsoft Windows 11 Installation Assistant. The script was designed to streamline upgrade operations for field devices, conference room systems, and managed Windows endpoints while enforcing pre‑upgrade safety checks and ensuring predictable results.
The solution includes pre‑flight validation, rollback window extension, secure download of the Installation Assistant, silent upgrade staging, and structured exit‑code handling. This documentation serves as a reference implementation for enterprise‑grade OS upgrade automation.

Objectives
• 	Automate the Windows 11 upgrade process using Microsoft‑supported tooling
• 	Enforce pre‑upgrade validation (disk space, AC power, prerequisites)
• 	Ensure predictable and safe upgrade behavior across diverse hardware
• 	Extend the OS rollback window for operational safety
• 	Provide clear operator guidance and structured logging
• 	Support silent, SYSTEM‑context execution for IT‑managed deployments
• 	Reduce manual effort and eliminate inconsistent upgrade attempts

Key Features
Pre‑Flight Validation
The script performs several checks before initiating the upgrade:
• 	Minimum 30 GB free on C:
• 	AC power verification (for laptops)
• 	Creation of a controlled working directory
• 	Operator guidance for TPM/Secure Boot/UEFI requirements
• 	Optional rollback window extension (30 days)
                           
Secure Download
• 	Retrieves the official Windows 11 Installation Assistant from Microsoft
• 	Validates download presence before execution
                           
Silent Upgrade Staging
• 	Runs the Installation Assistant with 
• 	Captures and reports exit codes
• 	Supports automated or manual reboot workflows
                           
Clear Logging & Error Handling
• 	Exit code mapping (0, 3010, failure conditions)
• 	Directs operators to Panther logs for troubleshooting
• 	Provides safe termination on pre‑check failures

Usage Instructions
1. Preparation
Copy the script to the device (C:\Temp\USB-Win11-Upgrade.ps1) and run from an elevated PowerShell session.
                           
2. Run Command
Set-ExecutionPolicy Bypass -Scope Process -Force
cd C:\Temp
.\USB-Win11-Upgrade.ps1
                           
3. After Running
• 	If exit code is 0 or 3010, reboot to complete the upgrade
• 	Verify OS version using 
• 	Validate key applications (e.g., Zoom Rooms)
• 	Rollback remains available for 30 days (extended by script)

Technical Summary
Pre‑Checks
• 	Disk space validation
• 	AC power validation
• 	Working directory creation
• 	Rollback window extension via DISM
                           
Upgrade Execution
• 	Downloads Installation Assistant
• 	Executes silent upgrade
• 	Captures exit codes
• 	Provides operator guidance
                           
Exit Code Handling

Code       Meaning
0          Success
3010       Success, reboot required
Other      Failure - review Panther logs
                           
Validation Results
✔ Successful upgrade staging across test devices
✔ Rollback window extended to 30 days
✔ Silent execution validated under Administrator context
✔ No data loss or application failures observed
✔ Panther logs confirmed clean upgrade paths
✔ Script safe for field deployment and IT‑assisted upgrades

Lessons Learned
                           
• 	Pre‑flight validation prevents the majority of upgrade failures
• 	Rollback window extension is essential for operational safety
• 	Silent staging reduces user disruption
• 	Panther logs remain the authoritative source for troubleshooting
• 	Automating the download ensures consistent use of the latest Assistant

Project Status
                           
✔ Completed
✔ Validated
✔ Ready for operational use
✔ Documentation preserved as a reference architecture
