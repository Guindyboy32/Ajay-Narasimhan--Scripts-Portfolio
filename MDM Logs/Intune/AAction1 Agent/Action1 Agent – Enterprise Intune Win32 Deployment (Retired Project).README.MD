Status: Completed & Retired

Project Overview
This project documents the full lifecycle of modernizing the deployment of the Action1 Agent within Microsoft Intune by transitioning from a legacy MSI deployment to a fully supported Win32 application model.
The previous deployment suffered from inaccurate detection logic, repeated reinstall attempts, and persistent false‑failure reporting in Intune.
This project resolved those issues through a complete repackaging effort, updated detection rules, and a controlled rollout strategy.
The deployment has since been retired, but the documentation remains as a reference implementation for enterprise‑grade Intune application modernization.

Objectives
- Replace the legacy Action1 deployment with a modern Win32 application package
- Correct inaccurate detection logic causing false installation failures
- Ensure clean reporting and compliance visibility in Intune
- Validate installation behavior across pilot devices
- Transition to a scalable, future‑proof deployment model
- Assign the updated package to all corporate Windows workstations

Packaging & Application Modernization
Win32 Packaging Steps
- Repackaged the Action1 MSI installer as a Win32 application using the Microsoft Win32 Content Prep Tool
- Implemented MSI product code–based detection, ensuring accurate reporting across all devices
- Published the application under Device context, aligning with Microsoft best practices
- Validated installation behavior under SYSTEM context

Why Win32 Packaging Was Required
The legacy MSI deployment reported failures due to outdated detection logic.
Devices repeatedly attempted reinstallations, generating noise and inaccurate compliance data.

Win32 packaging provided:
- Reliable detection
- Clean reporting
- Consistent installation behavior
- Better lifecycle control

Intune Configuration Summary

Install Behavior
- Silent installation
- SYSTEM‑context execution
- MSI‑based detection

Detection Logic
- Detection Type: MSI
- Product Code: (auto‑populated from Action1 MSI)
- Version check disabled to avoid false negatives

Assignments
- Assigned to a dynamic device group containing all Intune‑managed corporate Windows workstations
- Legacy deployment assignments removed after validation

Pilot Deployment & Validation
Deployment Timeline (Copy‑and‑Paste Ready)
## Deployment Timeline

| Event                     | Timestamp              |
|---------------------------|------------------------|
| Application Created       | 2026‑03‑31 09:34:36 AM |
| Device Check‑In           | 2026‑03‑31 09:39:43 AM |
| User Requested Install    | 2026‑03‑31 09:56:13 AM |
| Application Installed     | 2026‑03‑31 10:16:21 AM |
| IME Installed             | 2026‑02‑25 08:33:15 AM |

Validation Results
- ✔ Successful installation across all pilot devices
- ✔ MSI detection correctly identified existing installations
- ✔ No further false failures reported
- ✔ No repeated reinstall attempts
- ✔ Device dashboards and compliance reports normalized
- ✔ Legacy deployment safely retired


Technical Findings & Root Cause
Issue Identified
The original deployment used outdated detection logic that no longer matched the installed MSI footprint.

As a result:
- Intune could not detect the existing installation
- Devices repeatedly attempted reinstallations
- Intune reported persistent 0x80070643 failures
- Compliance dashboards appeared unhealthy

Root Cause
Incorrect detection logic from an earlier deployment configuration.

Resolution
- Repackaged the MSI as a Win32 app
- Implemented MSI‑based detection
- Reassigned the updated deployment
- Removed legacy assignments

Final Outcome

- The Action1 Agent Win32 application is now deployed to all corporate Windows workstations
- Reporting and compliance visibility are fully accurate
- Legacy deployment has been retired
- The project is complete and stable

Lessons Learned
- MSI product code detection is essential for accurate reporting
- Legacy deployments can silently break when detection logic drifts
- Win32 packaging provides superior lifecycle control
- Always validate uninstall and detection behavior during pilot testing
- Dynamic device groups simplify long‑term maintenance

Project Status
✔ Completed
✔ Validated
✔ Rolled out to production
✔ Legacy deployment retired
This project remains available as a reference architecture for future Intune application modernization efforts
