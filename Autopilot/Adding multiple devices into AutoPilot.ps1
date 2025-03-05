# Import CSV and upload devices
$csvFile = "C:\path\to\devices.csv"
$deviceList = Import-Csv -Path $csvFile

foreach ($device in $deviceList) {
    Add-AutoPilotDevice -SerialNumber $device.SerialNumber -HardwareHash $device.HardwareHash
}



# You will need to replace (Add-AutoPilotDevice) given by the MGraph API or Intune PShell Module. 