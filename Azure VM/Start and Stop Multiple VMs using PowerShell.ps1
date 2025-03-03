# Variables
$resourceGroup = "MyResourceGroup"
$vmNames = @("MyVM1", "MyVM2", "MyVM3")

# Start VMs
foreach ($vmName in $vmNames) {
    Start-AzVM -ResourceGroupName $resourceGroup -Name $vmName
}

# Stop VMs
foreach ($vmName in $vmNames) {
    Stop-AzVM -ResourceGroupName $resourceGroup -Name $vmName -Force
}
