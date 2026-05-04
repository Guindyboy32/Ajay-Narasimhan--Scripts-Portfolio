<#
.SYNOPSIS
Create a dynamic Azure AD device group for Windows Autopilot devices using Group Tag.

.DESCRIPTION
This script connects to Microsoft Graph (beta profile), builds a dynamic membership
rule based on Autopilot Group Tag, and creates a security-enabled dynamic device group.

Author: Ajay Narasimhan – Senior Systems Engineer
#>

# ---------------------------------------------
# Connect to Microsoft Graph
# ---------------------------------------------
Connect-MgGraph -Scopes "Group.ReadWrite.All"
Select-MgProfile -Name beta

# ---------------------------------------------
# Variables
# ---------------------------------------------
$GroupName        = "TestDomainKiosk-Autopilot-WIN11"
$GroupDescription = "Dynamic group for kiosk devices using GroupTag:KIOSK"
$GroupTagValue    = "TestDomainKiosk_Autopilot_AAD"

# Dynamic membership rule using Autopilot Group Tag
$DynamicRule = "(device.devicePhysicalIds -any (_ -eq `"GroupTag:$GroupTagValue`"))"

Write-Host "Creating dynamic device group with rule:"
Write-Host $DynamicRule -ForegroundColor Cyan

# ---------------------------------------------
# Create the dynamic device group
# ---------------------------------------------
try {
    $group = New-MgGroup `
        -DisplayName $GroupName `
        -Description $GroupDescription `
        -MailEnabled:$false `
        -MailNickname $GroupName `
        -SecurityEnabled:$true `
        -GroupTypes "DynamicMembership" `
        -MembershipRule $DynamicRule `
        -MembershipRuleProcessingState "On"

    Write-Host "✔ Group created successfully:" -ForegroundColor Green
    Write-Host "  Name: $($group.DisplayName)"
    Write-Host "  ID:   $($group.Id)"
}
catch {
    Write-Host "✖ Failed to create group" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor DarkYellow
}
