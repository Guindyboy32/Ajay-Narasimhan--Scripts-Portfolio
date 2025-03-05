# Export devices
Install-Module -Name Microsoft.Graph.Intune -Force
Connect-MSGraph

$devices = Get-AutoPilotRegisteredDevices
$devices | Export-Csv -Path "AutoPilotDevices.csv" -NoTypeInformation -Encoding UTF8


## Make sure you have the Intune permissons to run this. 
#This will export all the devices that you have registered to CSV File. 