This repository documents the full lifecycle of deploying Zoom Workplace (64‑bit) as a Win32 application in Microsoft Intune.
The project includes packaging, deployment architecture, uninstall remediation, SSO configuration, and validation across a controlled pilot group.
This deployment has since been retired, but the documentation remains available as a reference implementation for enterprise‑grade Intune Win32 application management.

Project Summary
This project delivered a fully automated, silent, and SSO‑enabled deployment of Zoom Workplace using Intune Win32 packaging.
Key outcomes included:
- Replacement of legacy Zoom client with modern Zoom Workplace
- MSI‑based installation and uninstallation for reliability under SYSTEM context
- Full SSO integration via MSI parameters
- Clean detection logic using MSI product codes
- Controlled pilot rollout with telemetry validation
- Documentation of uninstall issues and root‑cause remediation
This repository serves as a technical blueprint for similar enterprise deployments.

MSI installers are not included. Download the latest version from Zoom’s enterprise distribution portal.


1. Packaging Process
Workspace
C:\IntuneWIN\Zoom-Deployment


Win32 Content Prep Tool Configuration
|  |  | 
|  | C:\IntuneWIN\Zoom-Deployment | 
|  | ZoomInstallerFull.msi | 
|  | C:\IntuneWIN\Zoom-Deployment\Output | 


Output artifact:
ZoomInstallerFull.intunewin


This package was validated for:
- Silent install behavior
- SYSTEM‑context execution
- Intune Management Extension compatibility

2. Intune Application Configuration
App Metadata
- Name: Zoom Workplace (64 bit)
- Publisher: Zoom Video Communications
- Version: Auto‑extracted from MSI
- Branding:
- Official Zoom PNG logo
- Resized to 256×256 for Intune compliance

3. Program Commands
Install Command
msiexec /i "ZoomInstallerFull.msi" /quiet /qn /norestart /log install.log zNoDesktopShortcut=True zSSOHost="yourcompany.zoom.us"


Replace yourcompany.zoom.us with your organization’s Zoom SSO domain.

Uninstall Command (Recommended)
msiexec /x {964C2D69-6A45-4988-B74F-1A4176E457F6} /qn /norestart


Why MSI Uninstall Was Required
The legacy uninstall method:
Zoom.exe --uninstall --silent


failed under SYSTEM context due to WebView2 attempting to access:
C:\Windows\System32\config\systemprofile\AppData\Roaming\Zoom\Data\WebViewCacheX64


This caused uninstall failures during remediation and supersedence testing.
Switching to MSI uninstall resolved the issue and ensured consistent behavior across all device states.

4. Requirements
- Architecture: 64‑bit
- Minimum OS: Windows 10 1607
- Execution Context: SYSTEM (Intune Management Extension)

5. Detection Logic
- Detection Type: MSI
- Product Code: {964C2D69-6A45-4988-B74F-1A4176E457F6}
- Version Check: Disabled (Zoom updates frequently; version‑based detection not recommended)
This ensures accurate detection even when Zoom performs in‑place updates.

6. Dependencies
No dependencies required.
Zoom Workplace bundles all required runtimes.

7. Supersedence Strategy
Supersedence was intentionally not configured during the pilot phase.
Legacy Zoom clients were retired manually after validation to avoid:
- Conflicts between MSI and EXE‑based installers
- Uninstall failures due to WebView2 cache locks
- Unexpected user session interruptions

 8. Deployment & Validation

- **Application Created:** 2026‑03‑31 09:34:36 AM  
- **Device Check‑In:** 2026‑03‑31 09:39:43 AM  
- **User Requested Install:** 2026‑03‑31 09:56:13 AM  
- **Application Installed:** 2026‑03‑31 10:16:21 AM  
- **IME Installed:** 2026‑02‑25 08:33:15 AM  

Validation Summary
- ✔ Silent installation successful
- ✔ MSI uninstall validated
- ✔ Reinstallation tested
- ✔ Application launch verified
- ✔ SSO authentication confirmed
- ✔ No residual files or registry artifacts detected
- ✔ No IME or WebView2 errors observed

This deployment met all enterprise readiness criteria.

9. Retirement Notes
This project has been retired following successful rollout and transition to a newer application management strategy.
The documentation remains available for:
- Reference architecture
- Troubleshooting patterns
- MSI vs EXE uninstall considerations
- Intune Win32 packaging examples

10. Lessons Learned
- MSI‑based uninstall is mandatory for Zoom under SYSTEM context
- WebView2 cache paths can break scripted uninstalls
- MSI detection rules provide the most stable Intune experience
- SSO configuration via MSI parameters is reliable and predictable
- Pilot deployments should always validate uninstall behavior, not just install behavior

 License

This project is provided for educational and operational reference.
You may adapt it for your own environment.

🙌 Contributions
This project is retired, but suggestions and improvements are welcome for community benefit
