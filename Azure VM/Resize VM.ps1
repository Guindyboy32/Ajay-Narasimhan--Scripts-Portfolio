<#
.SYNOPSIS
    Resize an Azure Virtual Machine safely and predictably.

.DESCRIPTION
    This script performs a controlled resize of an Azure VM using:
      - Parameterized input
      - Validation checks
      - Structured logging
      - Error handling

    The VM is deallocated, resized, and restarted following Azure best practices.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$VmName,

    [Parameter(Mandatory = $true)]
    [string]$NewSize
)

Write-Host "------------------------------------------------------------"
Write-Host " Azure VM Resize Workflow"
Write-Host " VM: $VmName"
Write-Host " Resource Group: $ResourceGroupName"
Write-Host " Target Size: $NewSize"
Write-Host "------------------------------------------------------------"

try {
    # Validate Azure login
    if (-not (Get-AzContext)) {
        Write-Error "You are not logged into Azure. Run Connect-AzAccount first."
        exit 1
    }

    # Validate resource group
    if (-not (Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue)) {
        Write-Error "Resource group '$ResourceGroupName' does not exist."
        exit 1
    }

    # Validate VM existence
    $vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName -ErrorAction SilentlyContinue
    if (-not $vm) {
        Write-Error "VM '$VmName' does not exist in resource group '$ResourceGroupName'."
        exit 1
    }

    # Check if VM is already the desired size
    if ($vm.HardwareProfile.VmSize -eq $NewSize) {
        Write-Host "VM '$VmName' is already size '$NewSize'. No resize required." -ForegroundColor Yellow
        exit 0
    }

    Write-Host "Deallocating VM '$VmName'..." -ForegroundColor Cyan
    Stop-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName -Force

    Write-Host "Updating VM size to '$NewSize'..." -ForegroundColor Cyan
    $vm.HardwareProfile.VmSize = $NewSize
    Update-AzVM -ResourceGroupName $ResourceGroupName -VM $vm

    Write-Host "Starting VM '$VmName'..." -ForegroundColor Cyan
    Start-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName

    Write-Host "VM resize completed successfully." -ForegroundColor Green
}
catch {
    Write-Error "Failed to resize VM. Details: $_"
}
