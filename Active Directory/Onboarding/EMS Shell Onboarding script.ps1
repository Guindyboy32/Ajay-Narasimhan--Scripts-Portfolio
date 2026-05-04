<#
.SYNOPSIS
    Semi‑interactive new‑hire provisioning script for on‑prem AD + Exchange hybrid.

.DESCRIPTION
    This script:
        - Imports new hires from CSV
        - Applies template-based AD user creation
        - Stamps extension attributes
        - Updates manager
        - Creates remote mailbox
        - Applies SMTP policy
        - Provides clean, consistent confirmations

.AUTHOR
    Ajay Narasimhan
#>

# ==========================
# IMPORT CSV
# ==========================
$Users = Import-Csv "C:\NewHires.csv"

Write-Host "`nLoaded $($Users.Count) new hires from CSV." -ForegroundColor Cyan
Read-Host "Press ENTER to begin processing"

foreach ($u in $Users) {

    $sam = $u.samAccountName
    $upn = "$sam@TestDomain.com"
    $remote = "$sam@TestDomain2.mail.onmicrosoft.com"

    Write-Host "`n=============================================" -ForegroundColor DarkCyan
    Write-Host "Processing new hire: $sam" -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor DarkCyan

    # ==========================
    # PASSWORD PROMPT
    # ==========================
    $password = Read-Host "Enter temporary password for $sam" -AsSecureString

    # ==========================
    # TEMPLATE SELECTION
    # ==========================
    switch ($u.Template) {
        "TestSiteTemplateNFTE" { $template = "TestSiteTemplateNFTE" }
        "TestSiteTemplate"     { $template = "TestSiteTemplate" }
        default {
            Write-Host "Unknown template for $sam. Skipping user." -ForegroundColor Red
            continue
        }
    }

    Write-Host "Template selected: $template" -ForegroundColor Yellow
    Read-Host "Press ENTER to load template user"

    $templateUser = Get-ADUser $template -Properties *

    # ==========================
    # CREATE AD USER
    # ==========================
    Write-Host "Ready to create AD user: $sam" -ForegroundColor Yellow
    Read-Host "Press ENTER to create user"

    New-ADUser `
        -SamAccountName $sam `
        -UserPrincipalName $upn `
        -Name "$($u.FirstName) $($u.LastName)" `
        -GivenName $u.FirstName `
        -Surname $u.LastName `
        -Enabled $true `
        -AccountPassword $password `
        -Instance $templateUser `
        -Path "OU=TestSite,OU=San Francisco,OU=TestDomain Users,DC=TestDomain,DC=com"

    Write-Host "AD user created." -ForegroundColor Green

    # ==========================
    # EXTENSION ATTRIBUTES
    # ==========================
    Read-Host "Press ENTER to apply extension attributes"

    Set-ADUser $sam -Add @{
        extensionAttribute1  = $u.FullNameCaps
        extensionAttribute2  = $u.ManagerID
        extensionAttribute3  = $u.DeptSRVPName
        extensionAttribute4  = $u.DeptSRVPID
        extensionAttribute5  = $u.EmployeeLevel
        extensionAttribute10 = $u.StartDate
        extensionAttribute11 = $u.VPID
        extensionAttribute12 = $u.VPName
        extensionAttribute14 = $u.StartDate
        extensionAttribute15 = $u.EmployeeType
    }

    Write-Host "Extension attributes applied." -ForegroundColor Green

    # ==========================
    # TITLE / DEPARTMENT / ADDRESS
    # ==========================
    Read-Host "Press ENTER to apply Title, Department, and Address"

    Set-ADUser $sam `
        -Title $u.Title `
        -Department $u.Department `
        -StreetAddress $u.StreetAddress

    Write-Host "Title, Department, and Address applied." -ForegroundColor Green

    # ==========================
    # MANAGER UPDATE
    # ==========================
    Read-Host "Press ENTER to update manager"

    $manager = Get-ADUser -Filter "employeeID -eq '$($u.ManagerID)'" -Properties DistinguishedName

    if ($manager) {
        Set-ADUser $sam -Manager $manager.DistinguishedName
        Write-Host "Manager updated to: $($manager.DistinguishedName)" -ForegroundColor Green
    }
    else {
        Write-Host "Manager not found. Skipping." -ForegroundColor Yellow
    }

    # ==========================
    # OFFICE LOCATION
    # ==========================
    Read-Host "Press ENTER to set room number to Off-Site"

    Set-ADUser $sam -Replace @{ physicalDeliveryOfficeName = "offsite" }
    Write-Host "Room number set to Off-Site." -ForegroundColor Green

    # ==========================
    # REMOTE MAILBOX CREATION
    # ==========================
    Read-Host "Press ENTER to create remote mailbox"

    Enable-RemoteMailbox -Identity $sam -RemoteRoutingAddress $remote

    Start-Sleep -Seconds 2

    # ==========================
    # SMTP ADDRESS
    # ==========================
    Write-Host "Applying primary SMTP address..." -ForegroundColor Yellow
    Read-Host "Press ENTER to continue"

    try {
        Set-RemoteMailbox -Identity $sam -PrimarySmtpAddress $upn -EmailAddressPolicyEnabled $true -ErrorAction Stop
        Write-Host "SMTP applied with policy enabled." -ForegroundColor Green
    }
    catch {
        Write-Host "Policy conflict detected. Disabling policy..." -ForegroundColor Yellow
        Set-RemoteMailbox -Identity $sam -PrimarySmtpAddress $upn -EmailAddressPolicyEnabled $false
    }

    Start-Sleep -Seconds 2

    # ==========================
    # VALIDATION
    # ==========================
    Write-Host "Validating mailbox..." -ForegroundColor Yellow
    Read-Host "Press ENTER to show mailbox details"

    Get-RemoteMailbox $sam | Select Name,PrimarySmtpAddress,EmailAddresses | Format-List

    Write-Host "`nCompleted user: $sam" -ForegroundColor Cyan
    Read-Host "Press ENTER to continue to next user"
}
