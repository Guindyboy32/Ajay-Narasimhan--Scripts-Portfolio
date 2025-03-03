# Variables
$resourceGroup = "MyResourceGroup"
$vmName = "MyVM"
$shutdownTime = "1800"  # Time in HHMM format (24-hour clock)
$timeZone = "UTC"

# Enable Auto-Shutdown
$vm = Get-AzVM -ResourceGroupName $resourceGroup -Name $vmName
$vm.Tags["AutoShutdownTime"] = $shutdownTime
$vm.Tags["AutoShutdownTimeZone"] = $timeZone
Update-AzVM -ResourceGroupName $resourceGroup -VM $vm
