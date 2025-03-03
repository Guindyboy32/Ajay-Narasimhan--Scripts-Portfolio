# Variables
$resourceGroup = "MyResourceGroup"
$vmName = "MyVM"
$newVmSize = "Standard_DS3_v2"
$osDiskName = "NewOSDisk"

# Stop VM
Stop-AzVM -ResourceGroupName $resourceGroup -Name $vmName

# Update VM Size
$vm = Get-AzVM -ResourceGroupName $resourceGroup -Name $vmName
$vm.HardwareProfile.VmSize = $newVmSize
Update-AzVM -ResourceGroupName $resourceGroup -VM $vm

# Update OS Disk
$osDisk = Get-AzDisk -ResourceGroupName $resourceGroup -DiskName $osDiskName
$vm.StorageProfile.OsDisk.ManagedDisk = New-Object Microsoft.Azure.Management.Compute.Models.ManagedDiskParameters
$vm.StorageProfile.OsDisk.ManagedDisk.Id = $osDisk.Id
Update-AzVM -ResourceGroupName $resourceGroup -VM $vm

# Start VM
Start-AzVM -ResourceGroupName $resourceGroup -Name $vmName
