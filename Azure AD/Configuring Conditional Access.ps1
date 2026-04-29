<#
.SYNOPSIS
    Create a secure, enterprise‑grade Conditional Access policy in Azure AD / Entra ID.

.DESCRIPTION
    This script creates a Conditional Access policy using AzureAD/MS Graph.
    It includes parameter validation, structured logging, and error handling.
    Designed for identity governance, Zero Trust enforcement, and compliance workflows.

.NOTES
    Requires AzureADPreview module and directory write permissions.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$PolicyName,

    [Parameter(Mandatory = $true)]
    [string]$UserGroup,   # e.g., "All Users" or a specific group ID

    [Parameter(Mandatory = $true)]
    [string]$ApplicationScope # e.g., "All Applications" or specific App IDs
)

Write-Host "Creating Conditional Access Policy: $PolicyName" -ForegroundColor Cyan

try {
    # Validate module availability
    if (-not (Get-Module -ListAvailable -Name AzureADPreview)) {
        throw "AzureADPreview module is not installed. Install it using: Install-Module AzureADPreview"
    }

    # Resolve user scope
    $userCondition = if ($UserGroup -eq "All Users") {
        @{ IncludeUsers = @("All") }
    }
    else {
        @{ IncludeGroups = @($UserGroup) }
    }

    # Resolve application scope
    $appCondition = if ($ApplicationScope -eq "All Applications") {
        @{ IncludeApplications = @("All") }
    }
    else {
        @{ IncludeApplications = @($ApplicationScope) }
    }

    # Build policy object
    $conditions = @{
        Users        = $userCondition
        Applications = $appCondition
    }

    # Create policy
    $policy = New-AzureADMSConditionalAccessPolicy `
        -DisplayName $PolicyName `
        -State "Enabled" `
        -Conditions $conditions `
        -GrantControls @{ BuiltInControls = @("Mfa") } `
        -ErrorAction Stop

    Write-Host "Conditional Access Policy '$PolicyName' created successfully." -ForegroundColor Green
    Write-Host "User Scope: $UserGroup | App Scope: $ApplicationScope | Control: MFA enforced" -ForegroundColor DarkGray
}
catch {
    Write-Error "Failed to create Conditional Access Policy. Details: $_"
}
