<#
.SYNOPSIS
    Create an Azure Virtual Machine Scale Set (VMSS) with secure, validated, 
    and production‑ready configuration.

.DESCRIPTION
    This script builds a VM Scale Set using best practices:
    - Parameterized input
    - Validation of required resources
    - Secure credential handling
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
    [string]$VmssName,

    [Parameter(Mandatory = $true)]
    [string]$SubnetId,

    [Parameter(Mandatory = $true)]
    [ValidateRange(1, 1000)]
    [int]$InstanceCount,

    [Parameter(Mandatory = $true)]
    [string]$ImageSku,   # e.g., "2019-Datacenter"

    [Parameter(Mandatory = $true)]
    [string]$AdminUsername,

    [Parameter(Mandatory = $true)]
    [SecureString]$AdminPassword
)

Write-Host "Starting VM Scale Set creation workflow for '$VmssName'..." -ForegroundColor Cyan

try {
    # Validate Az module
    if (-not (Get-Module -ListAvailable -Name Az.Compute)) {
        throw "Az.Compute module is not installed. Install it using: Install-Module Az -Scope CurrentUser"
    }

    # Check if VMSS already exists
    $existingVmss = Get-AzVmss -ResourceGroupName $ResourceGroup -VMScaleSetName $VmssName -ErrorAction SilentlyContinue
    if ($existingVmss) {
        Write-Host "VM Scale Set '$VmssName' already exists. No action taken." -ForegroundColor Yellow
        return
    }

    Write-Host "Creating VMSS configuration..." -ForegroundColor Cyan

    # Base VMSS config
    $vmssConfig = New-AzVmssConfig `
        -Location $Location `
        -SkuCapacity $InstanceCount `
        -SkuName "Standard_DS1_v2" `
        -UpgradePolicyMode "Manual"

    # Storage profile
    $vmssConfig = Set-AzVmssStorageProfile `
        -VirtualMachineScaleSet $vmssConfig `
        -ImageReferencePublisher "MicrosoftWindowsServer" `
        -ImageReferenceOffer "WindowsServer" `
        -ImageReferenceSku $ImageSku `
        -ImageReferenceVersion "latest"

    # OS profile
    $vmssConfig = Set-AzVmssOsProfile `
        -VirtualMachineScaleSet $vmssConfig `
        -AdminUsername $AdminUsername `
        -AdminPassword $AdminPassword `
        -ComputerNamePrefix "vmss"

    # Network configuration
    $ipConfig = New-AzVmssIpConfig `
        -Name "vmssIPConfig" `
        -SubnetId $SubnetId

    $vmssConfig = Add-AzVmssNetworkInterfaceConfiguration `
        -VirtualMachineScaleSet $vmssConfig `
        -Name "vmssNIC" `
        -Primary `
        -IpConfiguration $ipConfig

    Write-Host "Deploying VM Scale Set '$VmssName'..." -ForegroundColor Cyan

    # Create VMSS
    New-AzVmss `
        -ResourceGroupName $ResourceGroup `
        -Name $VmssName `
        -VirtualMachineScaleSet $vmssConfig `
        -ErrorAction Stop

    Write-Host "VM Scale Set '$VmssName' created successfully." -ForegroundColor Green
}
catch {
    Write-Error "Failed to create VM Scale Set. Details: $_"
}
