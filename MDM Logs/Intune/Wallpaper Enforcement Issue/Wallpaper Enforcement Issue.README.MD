Wallpaper Enforcement Issue – Investigation, Root Cause, and Resolution Summary

Overview
This document summarizes the investigation into reports that Azure AD–joined Windows 11 devices were unable to change their desktop background. The issue was traced to an Intune Device Restrictions profile that was unintentionally applied to a broader device scope than originally intended. The configuration has now been corrected, and normal functionality has been restored.

Summary of Findings
During the review, we identified that the Intune Device Restrictions profile responsible for enforcing a corporate wallpaper—“CloudPC – Background”—was assigned to several device groups beyond its intended target.
Although the profile name indicates it was designed specifically for Windows 365 Cloud PCs, it was also assigned to general Windows 11 Azure AD–joined device groups. As a result, physical devices inherited the enforced wallpaper setting and were unable to change their desktop background.
In parallel, the separate Win32 wallpaper deployment (which sets the wallpaper once but does not enforce it) was functioning correctly and was not the source of the issue.

Root Cause
A configuration drift occurred in which a CloudPC‑specific Device Restrictions profile was inadvertently assigned to non‑CloudPC device groups. Because Device Restrictions enforce wallpaper settings at the OS level, all devices within those groups were prevented from modifying their background.
This behavior did not align with the intended design of the wallpaper deployment strategy.

Impact
- Physical Windows devices were unable to change their desktop wallpaper.
- Users experienced a degraded personalization experience, resulting in support tickets.
- The configuration did not match the intended scope of the policy.
- No security or compliance requirement justified enforcing wallpaper on physical devices.

Corrective Action (Completed)
To restore expected behavior, the following changes were implemented:

Removed from assignment:
- Azure AD–joined Windows 11 device groups
- Autopilot dynamic groups
- Migrated device groups

Retained:
- Windows 365 Cloud PC group
This ensures that only Cloud PCs continue to receive the enforced wallpaper, while physical devices revert to the expected behavior.
The Win32 wallpaper deployment remains assigned to all Windows devices and continues to set the corporate wallpaper once without enforcing it.

Expected Outcome

Cloud PCs
- Continue receiving the enforced corporate wallpaper
- Wallpaper cannot be changed (intended behavior)

Physical Windows Devices
- Retain the corporate wallpaper initially from the Win32 deployment
- Users can now freely change their wallpaper
- Restriction clears after the next Intune sync (typically within 30 minutes)

End Users
- No longer experience the “wallpaper locked” issue
- Maintain consistent branding on first login
- Regain full personalization control

Risk Assessment
Risk Level: Low
- No downtime
- No reboots required
- No impact to CloudPC functionality
- No removal of files or applications
- Immediate improvement to user experience
- Configuration now aligns with intended design

Status
The configuration correction has been successfully implemented.
No issues have been observed following deployment.
