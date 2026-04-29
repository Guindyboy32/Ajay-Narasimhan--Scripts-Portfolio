<#
.SYNOPSIS
    Deploy a fully configured Azure Virtual Machine with networking, NSG, public IP,
    and secure credentials using production‑grade engineering practices.

.DESCRIPTION
    This script provisions a complete Azure VM environment:
    - Resource group
    - Virtual network + subnet
    - Public IP
    - Network Security Group
    - NIC
    - VM configuration and deployment

    Includes:
    - Parameterization
    - Validation
    - Structured logging
    - Error handling
    - Idempotency checks

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
    [string]$ImageSku,   # e.g., "2019-Datacenter"

    [Parameter(Mandatory = $true)]
    [string]$VnetName,

    [Parameter(Mandatory = $true)]
    [string]$SubnetName,

    [Parameter(Mandatory = $true)]
    [string]$AddressPrefix,

    [Parameter(Mandatory = $true)]
    [string]$SubnetPrefix,

    [Parameter(Mandatory = $true)]
    [string]$AdminUsername,

    [Parameter(Mandatory = $true)]
    [SecureString]$AdminPassword
)

Write-Host "Starting VM deployment workflow for '$VmName'..." -ForegroundColor Cyan

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

    # Create Virtual Network
    Write-Host "Creating Virtual Network '$VnetName'..." -ForegroundColor Cyan
    $vnet = New-AzVirtualNetwork `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -Name $VnetName `
        -AddressPrefix $AddressPrefix

    # Create Subnet
    Write-Host "Adding Subnet '$SubnetName'..." -ForegroundColor Cyan
    $subnet = Add-AzVirtualNetworkSubnetConfig `
        -Name $SubnetName `
        -VirtualNetwork $vnet `
        -AddressPrefix $SubnetPrefix

    # Commit VNet changes
    $vnet | Set-AzVirtualNetwork | Out-Null

    # Create Public IP
    Write-Host "Creating Public IP..." -ForegroundColor Cyan
    $publicIP = New-AzPublicIpAddress `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -Name "$VmName-PIP" `
        -AllocationMethod Dynamic

    # Create Network Security Group
    Write-Host "Creating Network Security Group..." -ForegroundColor Cyan
    $nsg = New-AzNetworkSecurityGroup `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -Name "$VmName-NSG"

    # Create NIC
    Write-Host "Creating Network Interface..." -ForegroundColor Cyan
    $nic = New-AzNetworkInterface `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -Name "$VmName-NIC" `
        -SubnetId $subnet.Id `
        -PublicIpAddressId $publicIP.Id `
        -NetworkSecurityGroupId $nsg.Id

    # Create VM Configuration
    Write-Host "Building VM configuration..." -ForegroundColor Cyan
    $vmConfig = New-AzVMConfig `
        -VMName $VmName `
        -VMSize "Standard_DS1_v2" |
        Set-AzVMOperatingSystem `
            -Windows `
            -ComputerName $VmName `
            -Credential (New-Object System.Management.Automation.PSCredential($AdminUsername, $AdminPassword)) |
        Set-AzVMSourceImage `
            -PublisherName "MicrosoftWindowsServer" `
            -Offer "WindowsServer" `
            -Skus $ImageSku `
            -Version "latest" |
        Add-AzVMNetworkInterface `
            -Id $nic.Id

    # Deploy VM
    Write-Host "Deploying Virtual Machine '$VmName'..." -ForegroundColor Cyan
    New-AzVM `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -VM $vmConfig `
        -ErrorAction Stop

    Write-Host "VM '$VmName' deployed successfully." -ForegroundColor Green
}
catch {
    Write-Error "Failed to deploy VM. Details: $_"
}
