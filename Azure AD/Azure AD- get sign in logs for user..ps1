<#
.SYNOPSIS
    Export Azure AD / Entra ID sign‑in logs for a specific user.

.DESCRIPTION
    Retrieves sign‑in activity for a given User Principal Name (UPN) using
    Get-AzureADAuditSignInLogs and exports the results to a CSV file.
    Includes validation, structured output, and error handling suitable
    for security, audit, and compliance workflows.

.NOTES
    Requires AzureADPreview module and appropriate directory read permissions.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

Write-Host "Retrieving sign‑in logs for: $UserPrincipalName" -ForegroundColor Cyan

try {
    # Validate module availability
    if (-not (Get-Module -ListAvailable -Name AzureADPreview)) {
        throw "AzureADPreview module is not installed. Install it using: Install-Module AzureADPreview"
    }

    # Retrieve sign‑in logs
    $logs = Get-AzureADAuditSignInLogs -Filter "userPrincipalName eq '$UserPrincipalName'" `
        -ErrorAction Stop |
        Select-Object UserPrincipalName, AppDisplayName, CreatedDateTime, IPAddress, Status

    if (-not $logs) {
        Write-Warning "No sign‑in logs found for user: $UserPrincipalName"
        return
    }

    # Export to CSV
    $logs | Export-Csv -Path $OutputPath -NoTypeInformation
    Write-Host "Sign‑in logs exported successfully to: $OutputPath" -ForegroundColor Green
}
catch {
    Write-Error "Failed to retrieve or export sign‑in logs. Details: $_"
}
