# ================================
# Message Trace Script (10-Day)
# Author: Ajay Narasimhan
# ================================

# Prompt for email address (DL, mailbox, shared mailbox, etc.)
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

# Validate 10-day limit
if (($End - $Start).Days -gt 10) {
    Write-Host "Error: Get-MessageTrace only supports a 10-day range." -ForegroundColor Red
    exit
}

# Determine the folder where the script is located
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Build the CSV log file path inside the script folder
$LogFile = Join-Path $ScriptDir "MessageTraceLog_$(Get-Date -Format yyyyMMdd_HHmmss).csv"

Write-Host "Running message trace... please wait." -ForegroundColor Cyan

# Run the trace
$Results = Get-MessageTraceV2 -RecipientAddress $Recipient -StartDate $Start -EndDate $End

# Output results
if ($Results) {
    $Results | Export-Csv -Path $LogFile -NoTypeInformation
    Write-Host "Results found and saved to CSV: $LogFile" -ForegroundColor Green
}
else {
    "No results found for this date range." | Out-File $LogFile
    Write-Host "No results found. Details saved to CSV: $LogFile" -ForegroundColor Yellow
}
