<#
.SYNOPSIS
Assign Windows Autopilot devices to an Azure AD group using Microsoft Graph.

.DESCRIPTION
This script looks up Autopilot devices by Serial Number, retrieves their Azure AD
device object IDs, and adds them to a specified Azure AD security group.

Author: Ajay Narasimhan – Senior Systems Engineer
#>

# Group name to assign devices to
$groupName = "AutoPilot Devices Group"

# List of device serial numbers
$deviceSerials = @(
    "SerialNumber1",
    "SerialNumber2"
)

# Ensure Graph modules are installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.DeviceManagement)) {
    Install-Module Microsoft.Graph.DeviceManagement -Force
}
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Groups)) {
    Install-Module Microsoft.Graph.Groups -Force
}

# Connect to Graph
Connect-MgGraph -Scopes "Group.ReadWrite.All","Device.Read.All","DeviceManagementServiceConfig.Read.All"

# Get the Azure AD group
$group = Get-MgGroup -Filter "displayName eq '$groupName'"

if (-not $group) {
    Write-Host "Group '$groupName' not found." -ForegroundColor Red
    exit 1
}

Write-Host "Found group: $($group.DisplayName) [$($group.Id)]`n"

foreach ($serial in $deviceSerials) {

    Write-Host "Processing device with Serial Number: $serial..."

    # Find Autopilot device by serial number
    $apDevice = Get-MgDeviceManagementWindowsAutopilotDeviceIdentity `
        -Filter "serialNumber eq '$serial'"

    if (-not $apDevice) {
        Write-Host "✖ Autopilot device not found for serial: $serial" -ForegroundColor Red
        continue
    }

    # Get Azure AD device object ID
    $aadDeviceId = $apDevice.AzureAdDeviceId

    if (-not $aadDeviceId) {
        Write-Host "✖ Device has no Azure AD object ID yet (not synced)." -ForegroundColor Yellow
        continue
    }

    try {
        # Add device to group
        New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $aadDeviceId
        Write-Host "✔ Added device $serial to group '$groupName'" -ForegroundColor Green
    }
    catch {
        Write-Host "✖ Failed to add $serial to group: $_" -ForegroundColor Red
    }
}
