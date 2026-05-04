<#
.SYNOPSIS
Remove (deregister) a Windows Autopilot device from Intune using Microsoft Graph.

.DESCRIPTION
This script connects to Microsoft Graph, locates an Autopilot device by its
Autopilot Device ID, and removes it from the Autopilot service.

Author: Ajay Narasimhan – Senior Systems Engineer
#>

# Ensure required module is installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.DeviceManagement)) {
    Write-Host "Installing Microsoft.Graph.DeviceManagement module..."
    Install-Module Microsoft.Graph.DeviceManagement -Force
}

# Connect to Graph with required permissions
Connect-MgGraph -Scopes "DeviceManagementConfiguration.ReadWrite.All"

# Device ID to remove (replace with actual Autopilot Device ID)
$deviceId = "DeviceIDToRemove"

if (-not $deviceId) {
    Write-Host "No Device ID specified. Exiting." -ForegroundColor Red
    exit 1
}

Write-Host "Attempting to remove Autopilot device: $deviceId..."

try {
    Remove-MgDeviceManagementWindowsAutopilotDeviceIdentity `
        -WindowsAutopilotDeviceIdentityId $deviceId

    Write-Host "✔ Successfully removed Autopilot device: $deviceId" -ForegroundColor Green
}
catch {
    Write-Host "✖ Failed to remove device: $deviceId" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor DarkYellow
}
