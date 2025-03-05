# Get AutoPilot profiles
Install-Module -Name Microsoft.Graph.DeviceManagement -Force
Connect-MgGraph -Scopes "DeviceManagementConfiguration.Read.All"

$profiles = Get-MgDeviceManagementDeploymentProfile
$profiles | Format-Table displayName, description, outOfBoxExperience


#This script will retrieve AutoPilot profile. 
#This script will display the devices in table format
