<#
.SYNOPSIS
    Create or update an Azure AD / Entra ID password policy with strong security controls.

.DESCRIPTION
    This script defines and applies a password policy using AzureAD/MS Graph settings.
    It includes parameter validation, structured logging, and error handling suitable
    for enterprise identity governance and compliance workflows.

.NOTES
    Requires AzureADPreview module and directory write permissions.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$PolicyName,

    [Parameter(Mandatory = $true)]
    [bool]$EnforceComplexity,

    [Parameter(Mandatory = $true)]
    [ValidateRange(8, 128)]
    [int]$PasswordLength,

    [Parameter(Mandatory = $true)]
    [ValidateRange(1, 365)]
    [int]$PasswordValidityPeriod,

    [Parameter(Mandatory = $true)]
    [ValidateRange(1, 50)]
    [int]$PasswordHistoryCount
)

Write-Host "Applying password policy: $PolicyName" -ForegroundColor Cyan

try {
    # Validate module availability
    if (-not (Get-Module -ListAvailable -Name AzureADPreview)) {
        throw "AzureADPreview module is not installed. Install it using: Install-Module AzureADPreview"
    }

    # Apply password policy
    $result = New-AzureADMSPasswordSingleSignOnSettings `
        -DisplayName $PolicyName `
        -ComplexityEnabled $EnforceComplexity `
        -MinLength $PasswordLength `
        -ValidityPeriod $PasswordValidityPeriod `
        -HistoryCount $PasswordHistoryCount `
        -ErrorAction Stop

    Write-Host "Password policy '$PolicyName' applied successfully." -ForegroundColor Green
    Write-Host "Complexity: $EnforceComplexity | MinLength: $PasswordLength | Validity: $PasswordValidityPeriod days | History: $PasswordHistoryCount" -ForegroundColor DarkGray
}
catch {
    Write-Error "Failed to apply password policy. Details: $_"
}
