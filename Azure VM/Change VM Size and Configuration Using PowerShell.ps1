<#
.SYNOPSIS
    Resize an Azure VM and swap its OS disk safely and predictably.

.DESCRIPTION
    This script performs a controlled shutdown of a VM, updates its VM size,
    replaces the OS disk with a specified Managed Disk, and restarts the VM.
    Includes validation, idempotency checks, structured logging, and error handling.

.NOTES
    Requires Az PowerShell module and appropriate RBAC permissions.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroup,

    [Parameter(Mandatory = $true)]
    [string]$VMName,

    [Parameter(Mandatory = $true)]
    [string]$NewVmSize,

    [Parameter(Mandatory = $true)]
    [string]$NewOsDiskName
)

Write-Host "Starting VM resize and OS disk swap workflow for '$VMName'..." -ForegroundColor Cyan

try {
    # Validate Az module
    if (-not (Get-Module -ListAvailable -Name Az.Compute)) {
        throw "Az.Compute module is not installed. Install it using: Install-Module Az -Scope CurrentUser"
    }

    # Retrieve VM
    $vm = Get-AzVM -ResourceGroupName $ResourceGroup -VMName $VMName -ErrorAction Stop

    # Stop VM if running
    if ($vm.PowerState -ne "VM deallocated") {
        Write-Host "Stopping VM '$VMName'..." -ForegroundColor Yellow
        Stop-AzVM -ResourceGroupName $ResourceGroup -Name $VMName -Force
    }
    else {
        Write-Host "VM '$VMName' is already stopped." -ForegroundColor DarkGray
    }

    # Resize VM
    if ($vm.HardwareProfile.VmSize -eq $NewVmSize) {
        Write-Host "VM '$VMName' is already size '$NewVmSize'. Skipping resize." -ForegroundColor DarkGray
    }
    else {
        Write-Host "Updating VM size to '$NewVmSize'..." -ForegroundColor Cyan
        $vm.HardwareProfile.VmSize = $NewVmSize
        Update-AzVM -ResourceGroupName $ResourceGroup -VM $vm
        Write-Host "VM size updated successfully." -ForegroundColor Green
    }

    # Retrieve new OS disk
    $newOsDisk = Get-AzDisk -ResourceGroupName $ResourceGroup -DiskName $NewOsDiskName -ErrorAction Stop

    # Check if OS disk is already assigned
    if ($vm.StorageProfile.OsDisk.ManagedDisk.Id -eq $newOsDisk.Id) {
        Write-Host "OS disk '$NewOsDiskName' is already attached. Skipping disk swap." -ForegroundColor DarkGray
    }
    else {
        Write-Host "Swapping OS disk to '$NewOsDiskName'..." -ForegroundColor Cyan

        $vm.StorageProfile.OsDisk.ManagedDisk = New-Object Microsoft.Azure.Management.Compute.Models.ManagedDiskParameters
        $vm.StorageProfile.OsDisk.ManagedDisk.Id = $newOsDisk.Id

        Update-AzVM -ResourceGroupName $ResourceGroup -VM $vm

        Write-Host "OS disk swapped successfully." -ForegroundColor Green
    }

    # Start VM
    Write-Host "Starting VM '$VMName'..." -ForegroundColor Cyan
    Start-AzVM -ResourceGroupName $ResourceGroup -Name $VMName
    Write-Host "VM '$VMName' is now running with updated size and OS disk." -ForegroundColor Green
}
catch {
    Write-Error "Failed to resize VM or swap OS disk. Details: $_"
}
