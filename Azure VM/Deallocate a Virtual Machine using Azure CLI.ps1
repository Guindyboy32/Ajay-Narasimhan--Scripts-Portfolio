<#
.SYNOPSIS
    Deallocate an Azure Virtual Machine (PowerShell version).

.DESCRIPTION
    This script safely deallocates an Azure VM using:
      - Parameterized input
      - Validation
      - Structured logging
      - Error handling

    Suitable for automation pipelines and GitHub repositories.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$VmName
)

Write-Host "------------------------------------------------------------"
Write-Host " Azure VM Deallocation Workflow"
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

    # Validate VM
    if (-not (Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName -ErrorAction SilentlyContinue)) {
        Write-Error "VM '$VmName' does not exist in resource group '$ResourceGroupName'."
        exit 1
    }

    Write-Host "Deallocating VM '$VmName'..." -ForegroundColor Cyan

    Stop-AzVM `
        -ResourceGroupName $ResourceGroupName `
        -Name $VmName `
        -Force `
        -NoWait

    Write-Host "Deallocation request submitted successfully." -ForegroundColor Green
}
catch {
    Write-Error "Failed to deallocate VM. Details: $_"
}
