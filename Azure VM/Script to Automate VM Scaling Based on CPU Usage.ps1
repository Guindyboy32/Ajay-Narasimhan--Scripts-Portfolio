<#
.SYNOPSIS
    Perform a manual autoscale action on a VM Scale Set based on CPU usage.

.DESCRIPTION
    This script:
      - Validates Azure context
      - Retrieves VMSS metrics
      - Calculates average CPU over the last 10 minutes
      - Scales out the VMSS by one instance if CPU exceeds threshold
      - Provides structured logging and error handling

    This is a lightweight, controlled autoscale mechanism suitable for
    runbooks, scheduled tasks, or pipeline‑driven scaling.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$VmScaleSetName,

    [Parameter(Mandatory = $true)]
    [ValidateRange(1,100)]
    [int]$CpuThreshold
)

Write-Host "------------------------------------------------------------"
Write-Host " Azure VM Scale Set CPU Autoscale Workflow"
Write-Host " VMSS: $VmScaleSetName"
Write-Host " Resource Group: $ResourceGroupName"
Write-Host " CPU Threshold: $CpuThreshold%"
Write-Host "------------------------------------------------------------"

try {
    # Validate Azure login
    if (-not (Get-AzContext)) {
        Write-Error "You are not logged into Azure. Run Connect-AzAccount first."
        exit 1
    }

    # Validate VMSS existence
    $vmss = Get-AzVmss -ResourceGroupName $ResourceGroupName -VMScaleSetName $VmScaleSetName -ErrorAction SilentlyContinue
    if (-not $vmss) {
        Write-Error "VM Scale Set '$VmScaleSetName' does not exist in resource group '$ResourceGroupName'."
        exit 1
    }

    Write-Host "Retrieving CPU metrics for VMSS '$VmScaleSetName'..." -ForegroundColor Cyan

    # Retrieve CPU metrics for the last 10 minutes
    $metrics = Get-AzMetric `
        -ResourceId $vmss.Id `
        -MetricName "Percentage CPU" `
        -TimeGrain "PT1M" `
        -StartTime (Get-Date).AddMinutes(-10) `
        -EndTime (Get-Date)

    if (-not $metrics.Data) {
        Write-Error "No CPU metric data available for VMSS '$VmScaleSetName'."
        exit 1
    }

    # Calculate average CPU
    $averageCpu = ($metrics.Data | Measure-Object -Property Average -Average).Average
    $averageCpuRounded = [math]::Round($averageCpu, 2)

    Write-Host "Average CPU over last 10 minutes: $averageCpuRounded%" -ForegroundColor Yellow

    # Decision logic
    if ($averageCpu -gt $CpuThreshold) {
        Write-Host "CPU exceeds threshold. Scaling out VMSS..." -ForegroundColor Cyan

        $currentCapacity = $vmss.Sku.Capacity
        $vmss.Sku.Capacity = $currentCapacity + 1

        Update-AzVmss `
            -ResourceGroupName $ResourceGroupName `
            -VMScaleSetName $VmScaleSetName `
            -Sku $vmss.Sku `
            -ErrorAction Stop

        Write-Host "Scaled out VMSS from $currentCapacity to $($vmss.Sku.Capacity) instances." -ForegroundColor Green
    }
    else {
        Write-Host "CPU usage is within threshold. No scaling action taken." -ForegroundColor Green
    }
}
catch {
    Write-Error "Autoscale workflow failed. Details: $_"
}
