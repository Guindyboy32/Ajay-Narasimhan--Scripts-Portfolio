<#
.SYNOPSIS
Export Windows Autopilot registered devices using Microsoft Graph PowerShell.

.DESCRIPTION
This script connects to Microsoft Graph, retrieves all Autopilot device identities,
and exports them to a CSV file for auditing or documentation.

Author: Ajay Narasimhan – Senior Systems Engineer
#>

# Ensure required module is installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.DeviceManagement)) {
    Install-Module Microsoft.Graph.DeviceManagement -Force
}

# Connect to Graph with required permissions
Connect-MgGraph -Scopes "DeviceManagementServiceConfig.Read.All"

# Retrieve Autopilot devices
$devices = Get-MgDeviceManagementWindowsAutopilotDeviceIdentity

# Export to CSV
$devices | Export-Csv -Path "AutoPilotDevices.csv" -NoTypeInformation -Encoding UTF8

Write-Host "✔ Export complete. File saved as AutoPilotDevices.csv" -ForegroundColor Green
