# Install the Azure PowerShell module if not already installed
Install-Module -Name Az -AllowClobber -Scope CurrentUser

# Connect to Azure
Connect-AzAccount



#Create Virtual Machine. 

# Define resource group and VM properties
$resourceGroupName = "MyResourceGroup"
$location = "EastUS"
$vmName = "MyVM"
$vmSize = "Standard_B1s"
$image = Get-AzVMImage -Location $location -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest"
$adminUsername = "azureuser"
$adminPassword = ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force

# Create the resource group if it doesn't exist
if (-not (Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $resourceGroupName -Location $location
}

# Create a new virtual network
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location -Name "$vmName-VNet" -AddressPrefix "10.0.0.0/16"

# Create a new subnet
$subnet = Add-AzVirtualNetworkSubnetConfig -Name "$vmName-Subnet" -AddressPrefix "10.0.0.0/24" -VirtualNetwork $vnet
$vnet | Set-AzVirtualNetwork

# Create a public IP address
$publicIp = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Name "$vmName-PublicIP" -Location $location -AllocationMethod Dynamic

# Create a network security group
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Location $location -Name "$vmName-NSG"

# Create a NIC
$nic = New-AzNetworkInterface -ResourceGroupName $resourceGroupName -Location $location -Name "$vmName-NIC" -SubnetId $subnet.Id -PublicIpAddressId $publicIp.Id -NetworkSecurityGroupId $nsg.Id

# Create the VM configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize | `
    Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential (New-Object System.Management.Automation.PSCredential($adminUsername, $adminPassword)) | `
    Set-AzVMSourceImage -Id $image.Id | `
    Add-AzVMNetworkInterface -Id $nic.Id

# Create the VM
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig


####### Scaling down and scaling up. 

# Define the VM properties
$resourceGroupName = "MyResourceGroup"
$vmName = "MyVM"
$newVmSize = "Standard_B2s"  # New size

# Deallocate the VM
Stop-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -Force

# Resize the VM
Update-AzVM -ResourceGroupName $resourceGroupName -VM (Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName).HardwareProfile.VmSize = $newVmSize

# Start the VM
Start-AzVM -ResourceGroupName $resourceGroupName -Name $vmName

#######Monitor Aure rescources. 

# Define resource properties
$resourceGroupName = "MyResourceGroup"
$resourceId = "/subscriptions/your_subscription_id/resourceGroups/MyResourceGroup/providers/Microsoft.Compute/virtualMachines/MyVM"
$actionGroupName = "MyActionGroup"
$actionGroupEmail = "admin@example.com"

# Create an action group
$actionGroup = New-AzActionGroup -ResourceGroupName $resourceGroupName -Name $actionGroupName -ShortName "MyAG" -EmailReceiver "AdminAlert" -EmailAddress $actionGroupEmail

# Create a metric alert rule
Add-AzMetricAlertRuleV2 -ResourceGroupName $resourceGroupName -Name "CPUUsageAlert" -TargetResourceId $resourceId -Condition (New-AzMetricAlertRuleV2Criteria -MetricName "Percentage CPU" -TimeAggregation Average -Operator GreaterThan -Threshold 80) -WindowSize 5 -Frequency 5 -ActionGroupId $actionGroup.Id

