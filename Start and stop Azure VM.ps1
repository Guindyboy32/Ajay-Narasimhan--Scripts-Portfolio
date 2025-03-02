# Define parameters
$resourceGroupName = "MyResourceGroup"
$vmName = "MyVM"

# Start the VM
Start-AzVM -ResourceGroupName $resourceGroupName -Name $vmName

# Stop the VM
Stop-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -Force
