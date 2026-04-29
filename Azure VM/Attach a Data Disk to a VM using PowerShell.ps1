<#
.SYNOPSIS
    Create and attach a Managed Data Disk to an Azure Virtual Machine.

.DESCRIPTION
    This script creates a Managed Disk and attaches it to an existing Azure VM.
    It includes validation, idempotency checks, structured logging, and error handling.
    Designed for cloud engineering, platform automation, and infrastructure pipelines.

.NOTES
    Requires Az PowerShell module and appropriate RBAC permissions.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroup,

    [Parameter(Mandatory = $true)]
    [string]$VMName,

    [Parameter(Mandatory = $true)]
    [string]$Location,

    [Parameter(Mandatory = $true)]
    [string]$DiskName,

    [Parameter(Mandatory = $true)]
    [ValidateRange(1, 32767)]
    [int]$DiskSizeGB,

    [Parameter(Mandatory = $false)]
    [ValidateRange(0, 63)]
    [int]$Lun = 0
)

Write-Host "Starting disk attachment workflow for VM '$VMName'..." -ForegroundColor Cyan

try {
    # Validate Az module
    if (-not (Get-Module -ListAvailable -Name Az.Compute)) {
        throw "Az.Compute module is not installed. Install it using: Install-Module Az -Scope CurrentUser"
    }

    # Check if disk already exists
    $existingDisk = Get-AzDisk -ResourceGroupName $ResourceGroup -DiskName $DiskName -ErrorAction SilentlyContinue

    if ($existingDisk) {
        Write-Host "Managed Disk '$DiskName' already exists. Skipping creation." -ForegroundColor Yellow
        $dataDisk = $existingDisk
    }
    else {
        Write-Host "Creating Managed Disk '$DiskName' ($DiskSizeGB GB)..." -ForegroundColor Cyan

        $diskConfig = New-AzDiskConfig `
            -Location $Location `
            -CreateOption Empty `
            -DiskSizeGB $DiskSizeGB

        $dataDisk = New-AzDisk `
            -ResourceGroupName $ResourceGroup `
            -DiskName $DiskName `
            -Disk $diskConfig

        Write-Host "Managed Disk '$DiskName' created successfully." -ForegroundColor Green
    }

    # Retrieve VM
    $vm = Get-AzVM -ResourceGroupName $ResourceGroup -VMName $VMName -ErrorAction Stop

    # Check if disk is already attached
    $attached = $vm.StorageProfile.DataDisks | Where-Object { $_.ManagedDisk.Id -eq $dataDisk.Id }

    if ($attached) {
        Write-Host "Disk '$DiskName' is already attached to VM '$VMName'. No action taken." -ForegroundColor Yellow
        return
    }

    Write-Host "Attaching disk '$DiskName' to VM '$VMName' at LUN $Lun..." -ForegroundColor Cyan

    $vm = Add-AzVMDataDisk `
        -VM $vm `
        -Name $DiskName `
        -ManagedDiskId $dataDisk.Id `
        -Lun $Lun `
        -Caching ReadWrite `
        -CreateOption Attach

    # Update VM
    Update-AzVM -VM $vm -ResourceGroupName $ResourceGroup

    Write-Host "Disk '$DiskName' successfully attached to VM '$VMName'." -ForegroundColor Green
}
catch {
    Write-Error "Failed to attach disk. Details: $_"
}
