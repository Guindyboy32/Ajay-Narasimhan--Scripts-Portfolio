# Remove device
Install-Module -Name Microsoft.Graph.DeviceManagement -Force
Connect-MgGraph -Scopes "DeviceManagementConfiguration.ReadWrite.All"

Remove-MgDeviceManagementWindowsAutopilotDeviceIdentity -DeviceId "DeviceIDToRemove"


#You will need to replace (DeviceIDtoRemove) with the device that you want to remove.
#This uses Mgraph
#You can use this to deregister devices. 