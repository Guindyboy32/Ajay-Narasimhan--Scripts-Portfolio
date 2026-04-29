<#
.SYNOPSIS
    Start or stop multiple Azure Virtual Machines in a controlled, validated workflow.

.DESCRIPTION
    This script:
      - Validates Azure login
      - Confirms resource group existence
      - Verifies each VM before attempting operations
      - Starts all VMs, then stops all VMs
      - Provides structured logging and error handling

    Ideal for automation pipelines, runbooks, and operational tooling.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroup,

    [Parameter(Mandatory = $true)]
    [string[]]$VmNames
)

Write-Host "------------------------------------------------------------"
Write-Host " Azure VM Start/Stop Workflow"
Write-Host " Resource Group: $ResourceGroup"
Write-Host " Target VMs: $($VmNames -join ', ')"
Write-Host "------------------------------------------------------------"

try {
    # Validate Azure login
    if (-not (Get-AzContext)) {
        Write-Error "You are not logged into Azure. Run Connect-AzAccount first."
        exit 1
    }

    # Validate resource group
    if (-not (Get-AzResourceGroup -Name $ResourceGroup -ErrorAction SilentlyContinue)) {
        Write-Error "Resource group '$ResourceGroup' does not exist."
        exit 1
    }

    # -----------------------------
    # START VMs
    # -----------------------------
    Write-Host "Starting VMs..." -ForegroundColor Cyan

    foreach ($vmName in $VmNames) {
        $vm = Get-AzVM -ResourceGroupName $ResourceGroup -Name $vmName -ErrorAction SilentlyContinue

        if (-not $vm) {
            Write-Warning "Skipping '$vmName' — VM not found."
            continue
        }

        Write-Host "Starting VM '$vmName'..." -ForegroundColor Yellow
        Start-AzVM -ResourceGroupName $ResourceGroup -Name $vmName -ErrorAction Stop
    }

    Write-Host "All start operations completed." -ForegroundColor Green

    # -----------------------------
    # STOP VMs
    # -----------------------------
    Write-Host "Stopping VMs..." -ForegroundColor Cyan

    foreach ($vmName in $VmNames) {
        $vm = Get-AzVM -ResourceGroupName $ResourceGroup -Name $vmName -ErrorAction SilentlyContinue

        if (-not $vm) {
            Write-Warning "Skipping '$vmName' — VM not found."
            continue
        }

        Write-Host "Stopping VM '$vmName'..." -ForegroundColor Yellow
        Stop-AzVM -ResourceGroupName $ResourceGroup -Name $vmName -Force -ErrorAction Stop
    }

    Write-Host "All stop operations completed." -ForegroundColor Green
}
catch {
    Write-Error "VM start/stop workflow failed. Details: $_"
}
