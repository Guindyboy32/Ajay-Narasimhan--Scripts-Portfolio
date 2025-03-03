# Variables
$sourceResourceGroup = "MySourceResourceGroup"
$destinationResourceGroup = "MyDestinationResourceGroup"
$vmName = "MyVM"

# Move VM
Move-AzResource -DestinationResourceGroupName $destinationResourceGroup -ResourceId "/subscriptions/$subscriptionId/resourceGroups/$sourceResourceGroup/providers/Microsoft.Compute/virtualMachines/$vmName"
