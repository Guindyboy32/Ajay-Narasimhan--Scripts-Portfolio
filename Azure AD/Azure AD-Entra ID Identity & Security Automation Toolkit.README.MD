A collection of production‑ready, enterprise‑grade PowerShell automation tools for managing and securing Azure AD / Entra ID environments.
These scripts follow identity‑engineering best practices, including strong validation, structured logging, error handling, and Zero Trust‑aligned defaults.

This toolkit is designed for:
- Identity & Access Management (IAM) engineers
- Cloud security teams
- Governance & compliance teams
- Conditional Access administrators
- SOC analysts and incident responders

Each script is written to be:
- Secure — no hard‑coded values, strong guardrails
- Maintainable — clean structure, parameters, documentation
- Predictable — consistent behavior for automation pipelines
- Enterprise‑aligned — follows Microsoft identity best practices

Included Tools
1️⃣ Sign‑In Log Export Tool
Exports user‑specific sign‑in logs from Azure AD / Entra ID for audit, investigation, and compliance workflows.
Capabilities
- Filters by User Principal Name (UPN)
- Retrieves app name, timestamp, IP address, and authentication status
- Exports clean CSV output
- Includes module validation and error handling
Use Cases
- Security investigations
- Access reviews
- Incident response
- Compliance reporting

2️⃣ Password Policy Enforcement Tool
Creates or updates a strong password policy aligned with enterprise security standards.
Capabilities
- Enforces complexity
- Sets minimum length
- Defines password validity period
- Configures password history
- Includes parameter validation and structured logging
Use Cases
- Identity governance
- Compliance enforcement
- Security baselining
- Tenant hardening

3️⃣ Conditional Access Policy Creation Tool
Creates a secure Conditional Access policy using Zero Trust‑aligned defaults.
Capabilities
- Supports “All Users” or specific groups
- Supports “All Applications” or specific app IDs
- Enforces MFA via Grant Controls
- Includes module validation and error handling
- Clean, parameterized design

Use Cases
- Zero Trust rollout
- MFA enforcement
- Application access governance
- Identity security baselines

Engineering Principles
- Zero Trust by Default
Scripts enforce MFA, strong passwords, and secure access patterns.
- Parameterized & Reusable
No hard‑coded values — everything is passed as parameters for safety and flexibility.

Structured Logging
Readable, color‑coded output suitable for pipelines and SOC workflows.
- Strong Validation
- Module checks
- Range validation
- Scope validation
- Error handling with meaningful messages

 Enterprise‑Ready
Designed for real‑world identity governance, security operations, and compliance automation.

Technologies Used
- PowerShell 5/7
- AzureADPreview module
- Microsoft Graph Identity APIs
- Azure AD / Entra ID

Use Cases
This toolkit is ideal for:
- Hardening Azure AD / Entra ID tenants
- Automating identity governance
- Enforcing Zero Trust access controls
- Supporting SOC investigations
- Meeting compliance and audit requirements

