# Define parameters
$resourceGroupName = "MyResourceGroup"
$vmName = "MyVM"
$newSize = "Standard_DS3_v2"

# Resize the VM
Stop-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -Force
Update-AzVM -ResourceGroupName $resourceGroupName -VMName $vmName -Size $newSize
Start-AzVM -ResourceGroupName $resourceGroupName -Name $vmName
