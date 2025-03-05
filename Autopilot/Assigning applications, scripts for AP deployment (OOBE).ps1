#For example, you can use this script to assign applications during Autopilot deployment
#This will allow you to assign Scripts to device groups for OOBE Experience

# Example script to install an application
Install-PackageProvider -Name NuGet -Force
Install-Module -Name PSWindowsUpdate -Force
Import-Module PSWindowsUpdate
Get-WindowsUpdate -Install -AcceptAll -AutoReboot

#This script will install the updates during OOBE


