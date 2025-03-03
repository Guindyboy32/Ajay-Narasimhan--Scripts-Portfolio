# Define device ID
$DeviceId = "your-device-id"

# Wipe the device
Invoke-DeviceAction -DeviceId $DeviceId -Action wipe
