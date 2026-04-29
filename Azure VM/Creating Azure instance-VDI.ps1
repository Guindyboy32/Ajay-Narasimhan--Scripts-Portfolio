<#
.SYNOPSIS
    Deploy an Azure VM, resize it safely, and configure monitoring alerts.

.DESCRIPTION
    This script performs three major automation tasks:
      1. Deploys a fully configured Azure VM (networking, NSG, public IP, NIC)
      2. Resizes the VM safely (deallocate → resize → start)
      3. Creates Azure Monitor alerts with an Action Group

    Includes:
      - Parameterization
      - Validation
      - Idempotency checks
      - Structured logging
      - Error handling

.NOTES
    Requires Az PowerShell module and appropriate RBAC permissions.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroup,

    [Parameter(Mandatory = $true)]
    [string]$Location,

    [Parameter(Mandatory = $true)]
    [string]$VmName,

    [Parameter(Mandatory = $true)]
    [string]$VmSize,

    [Parameter(Mandatory = $true)]
    [string]$ImageSku,   # e.g., "2019-Datacenter"

    [Parameter(Mandatory = $true)]
    [string]$AdminUsername,

    [Parameter(Mandatory = $true)]
    [SecureString]$AdminPassword,

    [Parameter(Mandatory = $true)]
    [string]$NewVmSize,  # For scaling up/down

    [Parameter(Mandatory = $true)]
    [string]$ActionGroupEmail
)

Write-Host "Starting Azure VM automation workflow..." -ForegroundColor Cyan

try {
    # Validate Az module
    if (-not (Get-Module -ListAvailable -Name Az.Compute)) {
        throw "Az.Compute module is not installed. Install it using: Install-Module Az -Scope CurrentUser"
    }

    # Create Resource Group (idempotent)
    $rg = Get-AzResourceGroup -Name $ResourceGroup -ErrorAction SilentlyContinue
    if (-not $rg) {
        Write-Host "Creating Resource Group '$ResourceGroup'..." -ForegroundColor Cyan
        New-AzResourceGroup -Name $ResourceGroup -Location $Location | Out-Null
    }
    else {
        Write-Host "Resource Group '$ResourceGroup' already exists." -ForegroundColor DarkGray
    }

    # Create VNet
    Write-Host "Creating Virtual Network..." -ForegroundColor Cyan
    $vnet = New-AzVirtualNetwork `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -Name "$VmName-VNet" `
        -AddressPrefix "10.0.0.0/16"

    # Create Subnet
    Write-Host "Adding Subnet..." -ForegroundColor Cyan
    $subnet = Add-AzVirtualNetworkSubnetConfig `
        -Name "$VmName-Subnet" `
        -AddressPrefix "10.0.0.0/24" `
        -VirtualNetwork $vnet

    $vnet | Set-AzVirtualNetwork | Out-Null

    # Create Public IP
    Write-Host "Creating Public IP..." -ForegroundColor Cyan
    $publicIp = New-AzPublicIpAddress `
        -ResourceGroupName $ResourceGroup `
        -Name "$VmName-PublicIP" `
        -Location $Location `
        -AllocationMethod Dynamic

    # Create NSG
    Write-Host "Creating Network Security Group..." -ForegroundColor Cyan
    $nsg = New-AzNetworkSecurityGroup `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -Name "$VmName-NSG"

    # Create NIC
    Write-Host "Creating NIC..." -ForegroundColor Cyan
    $nic = New-AzNetworkInterface `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -Name "$VmName-NIC" `
        -SubnetId $subnet.Id `
        -PublicIpAddressId $publicIp.Id `
        -NetworkSecurityGroupId $nsg.Id

    # Get Image
    Write-Host "Retrieving VM image..." -ForegroundColor Cyan
    $image = Get-AzVMImage `
        -Location $Location `
        -PublisherName "MicrosoftWindowsServer" `
        -Offer "WindowsServer" `
        -Skus $ImageSku `
        -Version "latest"

    # Build VM Config
    Write-Host "Building VM configuration..." -ForegroundColor Cyan
    $vmConfig = New-AzVMConfig `
        -VMName $VmName `
        -VMSize $VmSize |
        Set-AzVMOperatingSystem `
            -Windows `
            -ComputerName $VmName `
            -Credential (New-Object System.Management.Automation.PSCredential($AdminUsername, $AdminPassword)) |
        Set-AzVMSourceImage -Id $image.Id |
        Add-AzVMNetworkInterface -Id $nic.Id

    # Deploy VM
    Write-Host "Deploying VM '$VmName'..." -ForegroundColor Cyan
    New-AzVM `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -VM $vmConfig `
        -ErrorAction Stop

    Write-Host "VM deployed successfully." -ForegroundColor Green

    # -------------------------
    # Resize VM
    # -------------------------
    Write-Host "Resizing VM to '$NewVmSize'..." -ForegroundColor Cyan

    Stop-AzVM -ResourceGroupName $ResourceGroup -Name $VmName -Force

    $vm = Get-AzVM -ResourceGroupName $ResourceGroup -Name $VmName
    $vm.HardwareProfile.VmSize = $NewVmSize

    Update-AzVM -ResourceGroupName $ResourceGroup -VM $vm

    Start-AzVM -ResourceGroupName $ResourceGroup -Name $VmName

    Write-Host "VM resized successfully." -ForegroundColor Green

    # -------------------------
    # Monitoring & Alerts
    # -------------------------
    Write-Host "Configuring Azure Monitor alerts..." -ForegroundColor Cyan

    $resourceId = "/subscriptions/$((Get-AzContext).Subscription.Id)/resourceGroups/$ResourceGroup/providers/Microsoft.Compute/virtualMachines/$VmName"

    $actionGroup = New-AzActionGroup `
        -ResourceGroupName $ResourceGroup `
        -Name "$VmName-ActionGroup" `
        -ShortName "AG" `
        -EmailReceiver "AdminAlert" -EmailAddress $ActionGroupEmail

    Add-AzMetricAlertRuleV2 `
        -ResourceGroupName $ResourceGroup `
        -Name "$VmName-CPUAlert" `
        -TargetResourceId $resourceId `
        -Condition (New-AzMetricAlertRuleV2Criteria -MetricName "Percentage CPU" -TimeAggregation Average -Operator GreaterThan -Threshold 80) `
        -WindowSize 5 `
        -Frequency 5 `
        -ActionGroupId $actionGroup.Id

    Write-Host "Monitoring configured successfully." -ForegroundColor Green
}
catch {
    Write-Error "Automation workflow failed. Details: $_"
}
