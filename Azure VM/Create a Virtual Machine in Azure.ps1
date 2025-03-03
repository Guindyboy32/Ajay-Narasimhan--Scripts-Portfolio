# Variables
$resourceGroup = "MyResourceGroup"
$location = "EastUS"
$vmName = "MyVM"
$image = "Win2019Datacenter"

# Create Resource Group
New-AzResourceGroup -Name $resourceGroup -Location $location

# Create Virtual Network
$virtualNetwork = New-AzVirtualNetwork `
  -ResourceGroupName $resourceGroup `
  -Location $location `
  -Name "MyVnet" `
  -AddressPrefix "10.0.0.0/16"

# Create Subnet
$subnet = Add-AzVirtualNetworkSubnetConfig `
  -Name "MySubnet" `
  -VirtualNetwork $virtualNetwork `
  -AddressPrefix "10.0.1.0/24"

# Create Public IP
$publicIP = New-AzPublicIpAddress `
  -ResourceGroupName $resourceGroup `
  -Location $location `
  -Name "MyPublicIP" `
  -AllocationMethod Dynamic

# Create Network Security Group
$nsg = New-AzNetworkSecurityGroup `
  -ResourceGroupName $resourceGroup `
  -Location $location `
  -Name "MyNSG"

# Create NIC
$nic = New-AzNetworkInterface `
  -ResourceGroupName $resourceGroup `
  -Location $location `
  -Name "MyNIC" `
  -SubnetId $subnet.Id `
  -PublicIpAddressId $publicIP.Id `
  -NetworkSecurityGroupId $nsg.Id

# Create VM Configuration
$vmConfig = New-AzVMConfig `
  -VMName $vmName `
  -VMSize "Standard_DS1_v2" `
  | Set-AzVMOperatingSystem `
  -Windows `
  -ComputerName $vmName `
  -Credential (Get-Credential) `
  | Set-AzVMSourceImage `
  -PublisherName "MicrosoftWindowsServer" `
  -Offer "WindowsServer" `
  -Skus $image `
  -Version "latest" `
  | Add-AzVMNetworkInterface `
  -Id $nic.Id

# Create VM
New-AzVM `
  -ResourceGroupName $resourceGroup `
  -Location $location `
  -VM $vmConfig
