# Connect to Microsoft Graph API
Connect-MSGraph

# Get all devices in Intune
Get-IntuneManagedDevice | Select-Object DeviceName, OperatingSystem, ComplianceState
