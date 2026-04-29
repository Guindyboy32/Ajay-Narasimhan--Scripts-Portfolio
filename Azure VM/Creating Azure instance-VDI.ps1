<#
.SYNOPSIS
    Safe, sanitized Azure VM automation script suitable for public GitHub repositories.

.DESCRIPTION
    This script:
      - Deploys an Azure VM
      - Resizes the VM
      - Configures Azure Monitor alerts

    All sensitive values (passwords, emails, subscription IDs) have been removed
    and replaced with parameters or placeholders to ensure the script is safe
    for public publishing.

.NOTES
    Replace all <PLACEHOLDER> values before running in a real environment.
#>

# -----------------------------
# PARAMETERS (SAFE FOR GITHUB)
# -----------------------------
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
    [string]$ImageSku,   # Example: "2019-Datacenter"

    [Parameter(Mandatory = $true)]
    [string]$AdminUsername,

    [Parameter(Mandatory = $true)]
    [SecureString]$AdminPassword,  # No plaintext passwords

    [Parameter(Mandatory = $true)]
    [string]$NewVmSize,  # Resize target

    [Parameter(Mandatory = $true)]
    [string]$ActionGroupEmail  # No real emails included
)

Write-Host "Starting Azure VM workflow..." -ForegroundColor Cyan

try {
    # -----------------------------
    # RESOURCE GROUP
    # -----------------------------
    $rg = Get-AzResourceGroup -Name $ResourceGroup -ErrorAction SilentlyContinue
    if (-not $rg) {
        New-AzResourceGroup -Name $ResourceGroup -Location $Location | Out-Null
    }

    # -----------------------------
    # NETWORKING
    # -----------------------------
    $vnet = New-AzVirtualNetwork `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -Name "$VmName-VNet" `
        -AddressPrefix "10.0.0.0/16"

    $subnet = Add-AzVirtualNetworkSubnetConfig `
        -Name "$VmName-Subnet" `
        -AddressPrefix "10.0.0.0/24" `
        -VirtualNetwork $vnet

    $vnet | Set-AzVirtualNetwork | Out-Null

    $publicIp = New-AzPublicIpAddress `
        -ResourceGroupName $ResourceGroup `
        -Name "$VmName-PublicIP" `
        -Location $Location `
        -AllocationMethod Dynamic

    $nsg = New-AzNetworkSecurityGroup `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -Name "$VmName-NSG"

    $nic = New-AzNetworkInterface `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -Name "$VmName-NIC" `
        -SubnetId $subnet.Id `
        -PublicIpAddressId $publicIp.Id `
        -NetworkSecurityGroupId $nsg.Id

    # -----------------------------
    # VM IMAGE
    # -----------------------------
    $image = Get-AzVMImage `
        -Location $Location `
        -PublisherName "MicrosoftWindowsServer" `
        -Offer "WindowsServer" `
        -Skus $ImageSku `
        -Version "latest"

    # -----------------------------
    # VM CONFIGURATION
    # -----------------------------
    $vmConfig = New-AzVMConfig `
        -VMName $VmName `
        -VMSize $VmSize |
        Set-AzVMOperatingSystem `
            -Windows `
            -ComputerName $VmName `
            -Credential (New-Object System.Management.Automation.PSCredential($AdminUsername, $AdminPassword)) |
        Set-AzVMSourceImage -Id $image.Id |
        Add-AzVMNetworkInterface -Id $nic.Id

    # -----------------------------
    # DEPLOY VM
    # -----------------------------
    New-AzVM `
        -ResourceGroupName $ResourceGroup `
        -Location $Location `
        -VM $vmConfig `
        -ErrorAction Stop

    # -----------------------------
    # RESIZE VM
    # -----------------------------
    Stop-AzVM -ResourceGroupName $ResourceGroup -Name $VmName -Force

    $vm = Get-AzVM -ResourceGroupName $ResourceGroup -Name $VmName
    $vm.HardwareProfile.VmSize = $NewVmSize

    Update-AzVM -ResourceGroupName $ResourceGroup -VM $vm

    Start-AzVM -ResourceGroupName $ResourceGroup -Name $VmName

    # -----------------------------
    # MONITORING (SAFE PLACEHOLDERS)
    # -----------------------------
    $subscriptionId = "<SUBSCRIPTION-ID>"   # Safe placeholder
    $resourceId = "/subscriptions/$subscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Compute/virtualMachines/$VmName"

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
}
catch {
    Write-Error "Workflow failed. Details: $_"
}
