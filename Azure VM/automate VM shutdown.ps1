<#
.SYNOPSIS
    Configure auto‑shutdown metadata tags on an Azure Virtual Machine.

.DESCRIPTION
    This script:
      - Validates Azure login
      - Confirms resource group and VM existence
      - Applies standardized auto‑shutdown tags
      - Provides structured logging and error handling

    These tags can be consumed by automation runbooks, policies,
    or external schedulers to enforce shutdown schedules.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroup,

    [Parameter(Mandatory = $true)]
    [string]$VmName,

    [Parameter(Mandatory = $true)]
    [ValidatePattern("^\d{4}$")]   # HHMM format
    [string]$ShutdownTime,

    [Parameter(Mandatory = $true)]
    [string]$TimeZone
)

Write-Host "------------------------------------------------------------"
Write-Host " Azure VM Auto‑Shutdown Tagging Workflow"
Write-Host " VM: $VmName"
Write-Host " Resource Group: $ResourceGroup"
Write-Host " Shutdown Time: $ShutdownTime ($TimeZone)"
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

    # Validate VM existence
    $vm = Get-AzVM -ResourceGroupName $ResourceGroup -Name $VmName -ErrorAction SilentlyContinue
    if (-not $vm) {
        Write-Error "VM '$VmName' does not exist in resource group '$ResourceGroup'."
        exit 1
    }

    # Ensure tags dictionary exists
    if (-not $vm.Tags) {
        $vm.Tags = @{}
    }

    Write-Host "Applying auto‑shutdown tags..." -ForegroundColor Cyan

    $vm.Tags["AutoShutdownTime"] = $ShutdownTime
    $vm.Tags["AutoShutdownTimeZone"] = $TimeZone

    Update-AzVM -ResourceGroupName $ResourceGroup -VM $vm -ErrorAction Stop

    Write-Host "Auto‑shutdown tags applied successfully." -ForegroundColor Green
}
catch {
    Write-Error "Failed to configure auto‑shutdown tags. Details: $_"
}
