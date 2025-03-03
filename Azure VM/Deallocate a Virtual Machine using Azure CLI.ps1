# Variables
resourceGroupName="MyResourceGroup"
vmName="MyVM"

# Deallocate VM
az vm deallocate --resource-group $resourceGroupName --name $vmName
