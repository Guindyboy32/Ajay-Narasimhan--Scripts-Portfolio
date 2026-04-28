GraphPad Prism 11 – Intune Win32 Deployment (Retired Project)

Overview

This repository documents the completed Microsoft Intune Win32 application packaging and deployment project for GraphPad Prism 11.
The project is now retired, and this repository is maintained solely for reference, historical tracking, and future packaging guidance.
All work related to packaging, configuration, detection logic, installation scripting, and deployment validation has been fully completed and verified across multiple managed Windows environments.
No application installers or licensed binaries are included in this repository.


Deployment Summary

The application was packaged as a Win32 app using the Microsoft Win32 Content Prep Tool and validated across:
- Windows 365 Cloud PC
- Local physical workstation
- Production user device

All functional tests passed:
- Silent installation
- Configuration file deployment
- Automatic removal of older Prism versions
- Detection rule validation
- User‑initiated uninstall via Company Portal

Application Details
App Metadata
- Name: GraphPad Prism 11
- Version: 11
- Installer Type: MSI (wrapped in Win32 package)
- Install Behavior: System
- Category: Business Applications

Installation Logic
Install Script (install.cmd)

The Win32 package includes an installation script responsible for preparing configuration paths, copying required XML files, and executing the MSI installer with the appropriate parameters.
@echo off
mkdir "C:\ProgramData\PrismConfig" 2>nul
copy "%~dp0PrismConfig.xml" "C:\ProgramData\PrismConfig" /Y

msiexec.exe /i "%~dp0InstallPrism11.msi" /quiet ^
    STARTUPCONFIGPATH="C:\ProgramData\PrismConfig" ^
    UNINSTALLPRISM9=1 ^
    UNINSTALLPRISM10=1

exit /b %errorlevel%


Script Responsibilities
- Creates the Prism configuration directory
- Copies PrismConfig.xml into the configuration path
- Executes a silent MSI installation
- Removes Prism 9 and Prism 10 if present
- Returns proper exit codes for Intune compliance

Uninstallation Logic
Uninstall Command
msiexec.exe /x {019251E4-51B0-493A-95E0-E015024F9379} /quiet /norestart


This command was validated through a user‑initiated uninstall via Company Portal.

Detection Rules
Detection was implemented using a file‑based rule:
- Rule Type: File Exists
- Path: C:\Program Files\GraphPad\Prism
This reliably identified successful installation across all test and production devices.

Assignments
The application was deployed to controlled access groups for testing and later assigned to the production access group.
Deployment settings included:
- Availability: As soon as possible
- Installation Deadline: As soon as possible
- User Notifications: All toast notifications enabled
- Delivery Optimization: Background download

Validation Summary
Cloud PC Testing
- Successful silent installation
- Detection rule validated
- No reboot required

Local Workstation Testing
- Successful installation under a standard user profile
- Configuration XML deployed correctly
- Older Prism versions removed automatically
- Application launched normally

Uninstall Validation
- Uninstall available via Company Portal
- Removal completed successfully
- Detection rule updated accordingly

Production User Validation
- Silent installation completed without issues
- Application functional post‑install
- No reboot required


Project Status
This project is retired.
No further updates or maintenance are planned.
The repository remains available for:
- Reference for future Win32 packaging
- Audit and compliance review
- Reuse of installation or detection logic
- Historical documentation
