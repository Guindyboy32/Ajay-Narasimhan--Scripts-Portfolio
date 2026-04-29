<#
.SYNOPSIS
    Move an Azure Virtual Machine to a different resource group.

.DESCRIPTION
    This script validates Azure context, checks resource existence,
    builds the correct resource ID dynamically, and safely moves
    the VM to a new resource group with structured logging and
    error handling.

.NOTES
    Safe for GitHub — no secrets, no subscription IDs, no sensitive metadata.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$SourceResourceGroup,

    [Parameter(Mandatory = $true)]
    [string]$DestinationResourceGroup,

    [Parameter(Mandatory = $true)]
    [string]$VmName
)

Write-Host "------------------------------------------------------------"
Write-Host " Azure VM Move Workflow"
Write-Host " VM: $VmName"
Write-Host " From: $SourceResourceGroup"
Write-Host " To:   $DestinationResourceGroup"
Write-Host "------------------------------------------------------------"

try {
    # Validate Azure login
    if (-not (Get-AzContext)) {
        Write-Error "You are not logged into Azure. Run Connect-AzAccount first."
        exit 1
    }

    # Validate source resource group
    if (-not (Get-AzResourceGroup -Name $SourceResourceGroup -ErrorAction SilentlyContinue)) {
        Write-Error "Source resource group '$SourceResourceGroup' does not exist."
        exit 1
    }

    # Validate destination resource group
    if (-not (Get-AzResourceGroup -Name $DestinationResourceGroup -ErrorAction SilentlyContinue)) {
        Write-Error "Destination resource group '$DestinationResourceGroup' does not exist."
        exit 1
    }

    # Validate VM existence
    $vm = Get-AzVM -ResourceGroupName $SourceResourceGroup -Name $VmName -ErrorAction SilentlyContinue
    if (-not $vm) {
        Write-Error "VM '$VmName' does not exist in resource group '$SourceResourceGroup'."
        exit 1
    }

    # Build resource ID dynamically (GitHub‑safe)
    $subscriptionId = (Get-AzContext).Subscription.Id
    $resourceId = "/subscriptions/$subscriptionId/resourceGroups/$SourceResourceGroup/providers/Microsoft.Compute/virtualMachines/$VmName"

    Write-Host "Moving VM '$VmName' to '$DestinationResourceGroup'..." -ForegroundColor Cyan

    Move-AzResource `
        -DestinationResourceGroupName $DestinationResourceGroup `
        -ResourceId $resourceId `
        -Force

    Write-Host "VM moved successfully." -ForegroundColor Green
}
catch {
    Write-Error "Failed to move VM. Details: $_"
}
