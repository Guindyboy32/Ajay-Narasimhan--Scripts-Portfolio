Overview
This repository documents the completed engineering work to standardize Outlook shared mailbox caching behavior across Cloud PCs and physical Windows devices. The goal of the project was to eliminate manual configuration steps during provisioning and ensure consistent Outlook performance and behavior for all user types.
The project evaluated multiple approaches and implemented a scalable, policy‑based solution using Microsoft 365 Cloud Policy.

Problem Statement
Outlook’s default behavior caches shared mailboxes locally. During Cloud PC provisioning, technicians were required to manually disable Download shared folders, which resulted in:
- Inconsistent configuration across devices
- Manual effort during onboarding
- Missed steps during provisioning
- Performance issues for users with large shared mailboxes
- Different behavior between Cloud PCs and physical devices

A centrally enforced policy was needed to standardize this setting.

Solution
Two approaches were evaluated:
Option 1 — Modify Office Customization Tool (OCT) Configuration
- Applied only during Office install/repair
- Not enforced
- Did not reliably solve Cloud PC provisioning issues

Option 2 — Deploy Microsoft 365 Cloud Policy (Implemented)
- Enforces consistent behavior across all devices
- Eliminates manual provisioning steps
- Reduces OST size and sync issues
- Applies to Cloud PCs, physical devices, contractors, and FTEs
- Easy to manage and update
This option was selected as the long‑term solution.

Executive & VIP Considerations
Because executives often rely heavily on shared mailboxes and require high performance:
- An Executive Exclusion Group was created
- Executives and EAs retain full caching
- Standard users receive the Cloud Policy
This hybrid approach ensures performance where needed while maintaining standardization across the broader environment.

Impact
Standard Users
- Minor slowdown when accessing shared mailbox content
- Server‑side search
- No offline access to shared mailbox mail

Executives / EAs
- Retain full caching
- No performance impact

Primary Mailbox
- Unaffected for all users

Risk Assessment

Risks
- Slower shared mailbox performance for standard users
- No offline access to shared mailbox mail

Mitigation
- Executive exclusion group
- Pilot testing
- User communication
- Monitoring post‑deployment
Residual Risk: Low to Medium

Rollout Plan
- Preparation
- Create Azure AD groups
- Identify executive users
- Pilot
- Apply Cloud Policy to IT/test group
- Monitor for 1–2 weeks
- Deployment
- Assign Cloud Policy to standard users
- Validate policy application
- Post‑Implementation
- Collect feedback
- Adjust group membership as needed

Backout Plan
If issues occur:
- Remove group assignment from the Cloud Policy
- Outlook reverts to default caching behavior automatically
- No reinstall required
- Reversion occurs within hours
Backout Risk: Low

Outcome
The Cloud Policy solution successfully standardized Outlook shared mailbox behavior across the environment, eliminated manual provisioning steps, and reduced support overhead. Executive performance requirements were preserved through targeted exclusions.
This project is now completed and documented for future reference.
