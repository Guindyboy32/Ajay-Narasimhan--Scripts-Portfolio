<#
.SYNOPSIS
Retrieve Windows Autopilot Deployment Profiles from Microsoft Intune

.DESCRIPTION
This script connects to Microsoft Graph using the Device Management scope,
retrieves all Autopilot deployment profiles, and displays them in a clean,
readable table format. Useful for auditing, documentation, and troubleshooting.

Author: Ajay Narasimhan – Senior Systems Engineer
#>

# Ensure required module is installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.DeviceManagement)) {
    Write-Host "Installing Microsoft.Graph.DeviceManagement module..."
    Install-Module -Name Microsoft.Graph.DeviceManagement -Force
}

# Connect to Microsoft Graph
Write-Host "Connecting to Microsoft Graph..."
Connect-MgGraph -Scopes "DeviceManagementConfiguration.Read.All"

# Retrieve profiles
Write-Host "Retrieving Autopilot deployment profiles..."
$profiles = Get-MgDeviceManagementDeploymentProfile

if (-not $profiles) {
    Write-Host "No Autopilot profiles found." -ForegroundColor Yellow
    return
}

# Display results
Write-Host "`nAutopilot Deployment Profiles:`n"
$profiles |
    Select-Object displayName, description, outOfBoxExperience |
    Format-Table -AutoSize
