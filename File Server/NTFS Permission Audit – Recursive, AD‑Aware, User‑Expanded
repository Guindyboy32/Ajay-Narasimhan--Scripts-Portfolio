<#
.SYNOPSIS
    NTFS Permission Audit (Full Recursive Hierarchy, Interactive Mode)
    - Prompts user for folder path
    - Prompts user for export path
    - Recursively scans ALL subfolders
    - Expands AD groups into actual users (nested included)
    - Handles BUILTIN + local accounts without errors
    - Skips large groups (Domain Users, Authenticated Users, etc.)
    - Filters by rights (Read, Write, ReadAndExecute, Modify, FullControl)
    - Outputs one row per expanded user
    - Saves CSV to user-specified location
#>

# Prompt for folder path
$FolderPath = Read-Host "Enter the FULL folder path you want to scan (example: \\TestDomain-TDFS01\DeptShares\IT_Operations)"

# Validate folder exists
if (-not (Test-Path $FolderPath)) {
    Write-Host "ERROR: Folder path does not exist. Exiting." -ForegroundColor Red
    exit
}

# Prompt for export path
$ExportPath = Read-Host "Enter the folder path where the report should be saved (example: C:\Temp)"

# Validate export path
if (-not (Test-Path $ExportPath)) {
    Write-Host "Export path does not exist. Creating it..."
    New-Item -ItemType Directory -Path $ExportPath -Force | Out-Null
}

# Rights filter (now includes Read + Write)
$RightsFilter = @("Read", "Write", "ReadAndExecute", "Modify", "FullControl")

# Ensure AD module is available
Import-Module ActiveDirectory -ErrorAction Stop

# Output file
$CsvFile = Join-Path $ExportPath "NTFS_Permission_Audit.csv"

# Prepare results array
$Results = New-Object System.Collections.Generic.List[Object]

# Function: Expand AD groups into users (recursive)
function Get-ExpandedUsers {
    param(
        [string]$Identity
    )

    # Ignore BUILTIN and local accounts
    if ($Identity -match "^BUILTIN\\" -or 
        $Identity -match "^NT AUTHORITY\\" -or 
        $Identity -match "^NT SERVICE\\") {
        return $Identity
    }

    # Extract SamAccountName portion
    $Sam = $Identity.Split('\')[-1]

    # Skip large/global groups that should not be expanded
    $SkipGroups = @(
        "Domain Users",
        "Authenticated Users",
        "Everyone",
        "Users"
    )

    if ($SkipGroups -contains $Sam) {
        return $Identity
    }

    # Try user lookup
    $user = Get-ADUser -Filter { SamAccountName -eq $Sam } -ErrorAction SilentlyContinue
    if ($user) {
        return $user.SamAccountName
    }

    # Try group lookup
    $group = Get-ADGroup -Filter { SamAccountName -eq $Sam } -ErrorAction SilentlyContinue
    if ($group) {

        # Check group size before expanding
        $memberCount = (Get-ADGroupMember -Identity $group -ErrorAction SilentlyContinue).Count
        if ($memberCount -gt 5000) {
            return $Identity   # too large to expand
        }

        $members = Get-ADGroupMember -Identity $group -Recursive -ErrorAction SilentlyContinue
        return $members |
            Where-Object { $_.ObjectClass -eq "user" } |
            Select-Object -ExpandProperty SamAccountName
    }

    # If not found in AD, return raw identity
    return $Identity
}

Write-Host "Scanning full folder hierarchy... this may take a while."

# Recursively get ALL folders
$Folders = Get-ChildItem -Path $FolderPath -Directory -Recurse -ErrorAction SilentlyContinue
$Folders += Get-Item -Path $FolderPath   # include top folder

foreach ($Folder in $Folders) {

    try {
        $Acl = Get-Acl -Path $Folder.FullName -ErrorAction Stop
    }
    catch {
        Write-Warning "Access denied: $($Folder.FullName)"
        continue
    }

    foreach ($Ace in $Acl.Access) {

        # RIGHTS FILTERING
        $match = $false
        foreach ($right in $RightsFilter) {
            if ($Ace.FileSystemRights.ToString() -match $right) {
                $match = $true
                break
            }
        }
        if (-not $match) { continue }

        # Identity
        $Identity = $Ace.IdentityReference.Value

        # Expand users (one row per expanded user)
        $ExpandedUsers = Get-ExpandedUsers -Identity $Identity

        foreach ($User in $ExpandedUsers) {

            $Results.Add([PSCustomObject]@{
                FolderPath   = $Folder.FullName
                Identity     = $Identity
                IdentityType = if ($Identity -match "\\") { "UserOrGroup" } else { "Unknown" }
                ExpandedUser = $User
                Rights       = $Ace.FileSystemRights
                AccessType   = $Ace.AccessControlType
                Inherited    = $Ace.IsInherited
            })
        }
    }
}

# Export to CSV
$Results | Export-Csv -Path $CsvFile -NoTypeInformation -Encoding UTF8

Write-Host "`nAudit complete. CSV saved to: $CsvFile" -ForegroundColor Green
