<#
.SYNOPSIS
    Restart an Azure Virtual Machine using PowerShell.

.DESCRIPTION
    This script safely restarts an Azure VM with:
      - Parameterized input
      - Validation checks
      - Structured logging
      - Error handling

    Uses Restart-AzVM instead of Restart-Computer, ensuring the restart
    happens through Azure rather than relying on OS‑level connectivity.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$VmName
)

Write-Host "------------------------------------------------------------"
Write-Host " Azure VM Restart Workflow"
Write-Host " VM: $VmName"
Write-Host " Resource Group: $ResourceGroupName"
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
    if (-not (Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName -ErrorAction SilentlyContinue)) {
        Write-Error "VM '$VmName' does not exist in resource group '$ResourceGroupName'."
        exit 1
    }

    Write-Host "Restarting VM '$VmName'..." -ForegroundColor Cyan

    Restart-AzVM `
        -ResourceGroupName $ResourceGroupName `
        -Name $VmName `
        -ErrorAction Stop

    Write-Host "VM restarted successfully." -ForegroundColor Green
}
catch {
    Write-Error "Failed to restart VM. Details: $_"
}
