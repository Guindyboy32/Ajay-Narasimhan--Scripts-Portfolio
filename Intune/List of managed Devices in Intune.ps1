# Get all devices and export to CSV
Get-IntuneManagedDevice | Select-Object DeviceName, OperatingSystem, ComplianceState | Export-Csv -Path "C:\Users\YourUsername\Documents\DeviceInventory.csv" -NoTypeInformation
