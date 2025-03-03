# Variables
$resourceGroup = "MyResourceGroup"
$vmName = "MyVM"

# Redeploy VM
Set-AzVM -ResourceGroupName $resourceGroup -Name $vmName -Redeploy
