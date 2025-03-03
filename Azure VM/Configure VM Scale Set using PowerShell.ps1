# Variables
$resourceGroup = "MyResourceGroup"
$location = "EastUS"
$vmssName = "MyVMScaleSet"
$image = "Win2019Datacenter"
$instanceCount = 2

# Create VM Scale Set
$vmssConfig = New-AzVmssConfig -Location $location -SkuCapacity $instanceCount -SkuName "Standard_DS1_v2" -UpgradePolicyMode "Manual"
$vmssConfig = Set-AzVmssStorageProfile -VirtualMachineScaleSet $vmssConfig -ImageReferencePublisher "MicrosoftWindowsServer" -ImageReferenceOffer "WindowsServer" -ImageReferenceSku $image -ImageReferenceVersion "latest"
$vmssConfig = Set-AzVmssOsProfile -VirtualMachineScaleSet $vmssConfig -AdminUsername "adminUser" -AdminPassword (ConvertTo-SecureString "password" -AsPlainText -Force) -ComputerNamePrefix "vmss"
$vmssConfig = Add-AzVmssNetworkInterfaceConfiguration -VirtualMachineScaleSet $vmssConfig -Name "vmssNIC" -Primary -IpConfiguration (New-AzVmssIpConfig -Name "vmssIPConfig" -SubnetId $subnet.Id)

New-AzVmss -ResourceGroupName $resourceGroup -Name $vmssName -VirtualMachineScaleSet $vmssConfig
