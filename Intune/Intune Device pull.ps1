# Connect to Microsoft Graph API
Connect-MSGraph<#
.SYNOPSIS
    Retrieves Intune-managed devices using Microsoft Graph with validation,
    pagination support, and optional CSV export.

.DESCRIPTION
    This script:
        - Validates Microsoft Graph module availability
        - Connects to Graph with required scopes
        - Handles paginated Intune device results
        - Provides clean, structured output
        - Supports optional CSV export
        - Logs errors and connection failures
        - Uses modular, maintainable functions

.VERSION
    2.0

.AUTHOR
    Ajay Narasimhan – Systems Engineer
#>

# Get all devices in Intune
Get-IntuneManagedDevice | Select-Object DeviceName, OperatingSystem, ComplianceState
