<#
.SYNOPSIS
    Redeploy an Azure Virtual Machine.

.DESCRIPTION
    This script safely redeploys an Azure VM using:
      - Parameterized input
      - Validation checks
      - Structured logging
      - Error handling

    Redeploying a VM moves it to a new Azure host, which can resolve
    underlying host issues such as boot failures or connectivity problems.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroup,

    [Parameter(Mandatory = $true)]
    [string]$VmName
)

Write-Host "------------------------------------------------------------"
Write-Host " Azure VM Redeploy Workflow"
Write-Host " VM: $VmName"
Write-Host " Resource Group: $ResourceGroup"
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

    Write-Host "Redeploying VM '$VmName'..." -ForegroundColor Cyan

    Set-AzVM `
        -ResourceGroupName $ResourceGroup `
        -Name $VmName `
        -Redeploy `
        -ErrorAction Stop

    Write-Host "VM redeploy request submitted successfully." -ForegroundColor Green
}
catch {
    Write-Error "Failed to redeploy VM. Details: $_"
}
