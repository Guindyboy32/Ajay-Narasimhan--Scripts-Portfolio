# Variables
$resourceGroup = "MyResourceGroup"
$vmName = "MyVM"
$location = "EastUS"
$dataDiskName = "MyDataDisk"
$diskSizeGB = 128

# Create Managed Disk
$dataDisk = New-AzDisk `
  -ResourceGroupName $resourceGroup `
  -DiskName $dataDiskName `
  -Disk `
  -DiskSizeGB $diskSizeGB `
  -Location $location

# Get VM
$vm = Get-AzVM -ResourceGroupName $resourceGroup -VMName $vmName

# Add Data Disk to VM
$vm = Add-AzVMDataDisk -VM $vm -Name $dataDiskName -ManagedDiskId $dataDisk.Id -Caching ReadWrite -Lun 0 -CreateOption Attach

# Update VM
Update-AzVM -VM $vm -ResourceGroupName $resourceGroup
