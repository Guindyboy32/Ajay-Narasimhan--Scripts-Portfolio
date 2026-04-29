<#
.SYNOPSIS
    Start and stop an Azure Virtual Machine safely and predictably.

.DESCRIPTION
    This script:
      - Validates Azure login
      - Confirms resource group existence
      - Verifies VM existence
      - Starts the VM, then stops it
      - Provides structured logging and error handling

    Ideal for automation pipelines, runbooks, and operational tooling.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$VmName
)

Write-Host "------------------------------------------------------------"
Write-Host " Azure VM Start/Stop Workflow"
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

    # -----------------------------
    # START VM
    # -----------------------------
    Write-Host "Starting VM '$VmName'..." -ForegroundColor Cyan
    Start-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName -ErrorAction Stop
    Write-Host "VM started successfully." -ForegroundColor Green

    # -----------------------------
    # STOP VM
    # -----------------------------
    Write-Host "Stopping VM '$VmName'..." -ForegroundColor Cyan
    Stop-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName -Force -ErrorAction Stop
    Write-Host "VM stopped successfully." -ForegroundColor Green
}
catch {
    Write-Error "VM start/stop workflow failed. Details: $_"
}
