Utilities & Services – Automation Scripts

This folder contains a collection of PowerShell automation scripts focused on Windows services, system maintenance, network health, and security operations. These scripts are designed to help administrators streamline routine tasks, improve system reliability, and maintain consistent operational standards across servers and workstations.
These tools are intended for IT professionals with a working understanding of Windows Server, PowerShell, and basic infrastructure concepts.

Purpose
The scripts in this directory help automate:
- Service restarts
- Network health checks
- Security auditing
- Windows Update maintenance
- General system reliability tasks

Each script is modular and can be executed independently.

Script Index

Service & System Maintenance

- Service restart automation.ps1
Automatically restarts specified Windows services and logs the results.

- Clear Windows Update Cache.ps1
Clears the Windows Update cache to resolve update failures or stuck updates.

Network & Security Operations

- Automate network health checks.ps1
Runs automated checks for network connectivity, latency, DNS resolution, and other core network functions.
- Automate security audits.ps1
Performs automated security checks such as account status, password policies, service configurations, and event log scanning.

Requirements
To run these scripts, ensure you have:
- PowerShell 7.x or Windows PowerShell 5.1
- Local administrator rights (required for service and update operations)
- Network admin or security admin permissions (for audit and health check scripts)

 Notes
- Always test scripts in a non‑production environment before deploying widely.
- Some scripts may restart services or modify system state—review carefully before running.
- Update variables inside each script (service names, paths, thresholds) to match your environment.

