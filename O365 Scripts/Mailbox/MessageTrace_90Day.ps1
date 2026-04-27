# ================================
# Historical Message Trace Script (90-Day)
# Author: Ajay Narasimhan
# ================================

# Prompt for email address
$Recipient = Read-Host "Enter the mailbox or DL email address"

# Prompt for start and end dates
$StartDate = Read-Host "Enter Start Date (YYYY-MM-DD)"
$EndDate   = Read-Host "Enter End Date (YYYY-MM-DD)"

# Validate date format
try {
    $Start = [DateTime]::Parse($StartDate)
    $End   = [DateTime]::Parse($EndDate)
}
catch {
    Write-Host "Invalid date format. Please use YYYY-MM-DD." -ForegroundColor Red
    exit
}

# Validate 90-day limit
if (($End - $Start).Days -gt 90) {
    Write-Host "Error: Historical search only supports up to 90 days." -ForegroundColor Red
    exit
}

# Determine script folder
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Build log file path
$LogFile = Join-Path $ScriptDir "HistoricalTraceJob_$(Get-Date -Format yyyyMMdd_HHmmss).csv"

Write-Host "Submitting historical message trace... please wait." -ForegroundColor Cyan

# Submit historical search
$Job = Start-HistoricalSearch `
    -ReportTitle "HistoricalTrace_$Recipient" `
    -StartDate $Start `
    -EndDate $End `
    -RecipientAddress $Recipient `
    -ReportType MessageTrace

# Save job info
$Job | Export-Csv -Path $LogFile -NoTypeInformation

Write-Host "Historical trace submitted successfully." -ForegroundColor Green
Write-Host "Job ID: $($Job.JobId)"
Write-Host "Job details saved to: $LogFile" -ForegroundColor Green

Write-Host ""
Write-Host "To check job status, run:" -ForegroundColor Yellow
Write-Host "Get-HistoricalSearch -JobId $($Job.JobId)"
Write-Host ""
Write-Host "When complete, download the CSV from the Exchange Admin Center:" -ForegroundColor Yellow
Write-Host "https://admin.exchange.microsoft.com/#/messagetrace"
