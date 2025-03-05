# Example to assign devices to a group
$groupName = "AutoPilot Devices Group"
$deviceSerials = @("SerialNumber1", "SerialNumber2")

foreach ($serial in $deviceSerials) {
    Add-DeviceToGroup -DeviceSerial $serial -GroupName $groupName
}



## You can assign devices to the AP deployment group. Makes work eaiser, when you have to add multiple devices. 
## You will need to replace the add-devicetogroup function if architecture is combined with Azure AD and Intune.   