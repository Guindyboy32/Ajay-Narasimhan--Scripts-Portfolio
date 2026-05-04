<#
TestDomainOffboarding.ps1 (Full, corrected)
1) Disable account
2) Scramble password
3) Snapshot groups -> CSV
4) Remove all direct groups EXCEPT those matching -KeepGroupsPattern (default: Domain Users)
5) Hide from address lists (msExchHideFromAddressLists = $true)
6) Move to: OU=Inactive,DC=TestDomain,DC=local
7) Intune mobile cleanup (iOS/Android only) — safe & idempotent
#>

[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
param(
  [Parameter(Mandatory=$true)][string]$UserId,                    # sAM or UPN
  [string]$EvidencePath = $env:TEMP,                              # where CSV is saved
  [string]$TargetDisabledOU = 'OU=Inactive,DC=TestDomain,DC=local',
  [int]$PasswordLength = 24,
  [string]$KeepGroupsPattern = '^Domain Users$',                  # groups to KEEP (regex)
  [switch]$IntuneDryRun = $true                                   # Intune runs with -WhatIf by default in TestDomain
)

$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory -ErrorAction Stop

function Resolve-User {
  param([string]$Id)
  if ($Id -like '*@*') {
    Get-ADUser -Filter "UserPrincipalName -eq '$Id'" -Properties UserPrincipalName,SamAccountName,DistinguishedName,Enabled,memberOf,PrimaryGroupID
  } else {
    Get-ADUser -Identity $Id -Properties UserPrincipalName,SamAccountName,DistinguishedName,Enabled,memberOf,PrimaryGroupID
  }
}

function New-RandomPassword {
  param([int]$Length = 24)
  $upper   = 65..90  | ForEach-Object {[char]$_}
  $lower   = 97..122 | ForEach-Object {[char]$_}
  $digits  = 48..57  | ForEach-Object {[char]$_}
  # Expanded symbol set (includes '.' and ',')
  $symbols = '!','@','#','$','%','^','&','*','-','.',',','_','+','=','?'
  $all = $upper + $lower + $digits + $symbols
  $pw  = @()
  $pw += ($upper   | Get-Random)
  $pw += ($lower   | Get-Random)
  $pw += ($digits  | Get-Random)
  $pw += ($symbols | Get-Random)
  for ($i = $pw.Count; $i -lt $Length; $i++) { $pw += ($all | Get-Random) }
  -join ($pw | Sort-Object { Get-Random })
}

function Write-Step {
  param([string]$Msg)
  Write-Host ("[{0}] {1}" -f (Get-Date).ToString('s'), $Msg)
}

# ---------------------- MAIN ----------------------
try {
  $user = Resolve-User -Id $UserId
  if (-not $user) { throw "User '$UserId' not found." }

  $userSam = [string]$user.SamAccountName
  $userUPN = [string]$user.UserPrincipalName
  $userDN  = [string]$user.DistinguishedName

  Write-Step "User: $userSam | UPN: $userUPN | DN: $userDN | Enabled: $($user.Enabled)"
  Write-Verbose "Target OU: $TargetDisabledOU"

  # --- 1) Disable account ---
  if ($user.Enabled -eq $true) {
    if ($PSCmdlet.ShouldProcess($userSam, "Disable-ADAccount")) {
      Disable-ADAccount -Identity $userDN -Confirm:$false
      Write-Host "[1/6] Disabled account"
    }
  } else { Write-Host "[1/6] Already disabled" }

  # --- 2) Scramble password ---
  if ($PSCmdlet.ShouldProcess($userSam, "Reset password to random value")) {
    $newPlain = New-RandomPassword -Length $PasswordLength
    $secure   = ConvertTo-SecureString -String $newPlain -AsPlainText -Force
    Set-ADAccountPassword -Identity $userDN -Reset -NewPassword $secure -Confirm:$false
    # Optional: enforce cannot change / expire as needed
    Set-ADUser -Identity $userDN -ChangePasswordAtLogon:$false -PasswordNeverExpires:$false -Confirm:$false
    Write-Host "[2/6] Password scrambled"
  }

  # --- 3) Snapshot groups -> CSV ---
  $ts           = Get-Date -Format 'yyyyMMdd-HHmmss'
  $evidenceDir  = (New-Item -Path $EvidencePath -ItemType Directory -Force).FullName
  $csvPath      = Join-Path $evidenceDir "$($userSam)-groups-$ts.csv"

  $snap = Get-ADPrincipalGroupMembership -Identity $userDN | Sort-Object Name
  $snap | Select-Object @{n='SamAccountName';e={$userSam}},
                        @{n='UPN';e={$userUPN}},
                        @{n='GroupName';e={$_.Name}},
                        DistinguishedName,
                        GroupCategory,
                        GroupScope |
         Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
  Write-Host "[3/6] Group snapshot saved: $csvPath"

  # --- 4) Remove ALL direct groups except those matching KeepGroupsPattern ---
  # Use memberOf (direct only) so Remove-ADGroupMember won't fail on nested memberships.
  $directGroupDNs = (Get-ADUser -Identity $userDN -Properties memberOf).memberOf
  if ($directGroupDNs) {
    $directGroups = $directGroupDNs | ForEach-Object { Get-ADGroup -Identity $_ -Properties Name,DistinguishedName }
    $toRemove = $directGroups | Where-Object { $_.Name -notmatch $KeepGroupsPattern }
    if ($toRemove) {
      foreach ($g in $toRemove) {
        if ($PSCmdlet.ShouldProcess("$userSam from $($g.Name)", "Remove-ADGroupMember")) {
          try {
            Remove-ADGroupMember -Identity $g.DistinguishedName -Members $userDN -Confirm:$false -ErrorAction Stop
            Write-Host "     Removed from: $($g.Name)"
          } catch {
            Write-Warning "     Failed removing from $($g.Name): $($_.Exception.Message)"
          }
        }
      }
      Write-Host "[4/6] Direct group removals complete"
    } else {
      Write-Host "[4/6] No removable direct groups (matched KeepGroupsPattern or none)."
    }
  } else {
    Write-Host "[4/6] No direct group memberships to remove."
  }

  # --- 5) Hide from address lists ---
  if ($PSCmdlet.ShouldProcess($userSam, "Set msExchHideFromAddressLists = TRUE")) {
    try {
      Set-ADUser -Identity $userDN -Replace @{ 'msExchHideFromAddressLists' = $true } -Confirm:$false
      Write-Host "[5/6] Hidden from address lists"
    } catch {
      Write-Warning "Set msExchHideFromAddressLists failed: $($_.Exception.Message)"
    }
  }

  # --- 6) Move to Inactive OU ---
  if ($userDN -notmatch [regex]::Escape($TargetDisabledOU)) {
    if ($PSCmdlet.ShouldProcess($userSam, "Move-ADObject to $TargetDisabledOU")) {
      Move-ADObject -Identity $userDN -TargetPath $TargetDisabledOU -Confirm:$false
      Write-Host "[6/6] Moved to Inactive OU"
    }
  } else { Write-Host "[6/6] Already in Inactive OU" }

} catch {
  Write-Error "Offboarding failed: $($_.Exception.Message)"
  exit 1
}

# ============================================================================
# Intune Mobile Cleanup (TestDomain) — Safe & Idempotent
# Targets ONLY iOS/Android devices for the offboarded user; idempotent; honors -WhatIf.
# ============================================================================

function Remove-IntuneMobileDevicesForUser {
  [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
  param(
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$UserPrincipalName,
    [Parameter()][ValidateSet('Retire','Delete')][string]$Mode = 'Retire'
  )

  begin {
    function Is-MobileOs { param([string]$Os) if ([string]::IsNullOrWhiteSpace($Os)) { return $false } return ($Os -match '^iOS$' -or $Os -match '^Android') }
    function Is-AlreadyDone { param($Device) $state = ($Device.ManagementState | Out-String).Trim().ToLowerInvariant(); $retiredish = @('retired','retirepending','wiped','wipepending','retirefailed','wipefailed'); return $retiredish -contains $state }
  }
  process {
    $user = Get-MgUser -Filter "userPrincipalName eq '$UserPrincipalName'"
    if (-not $user) { throw "User '$UserPrincipalName' not found in Graph." }
    if ($user.Count -gt 1) { throw "Multiple users matched '$UserPrincipalName'." }
    $userId = $user[0].Id

    $devices = Get-MgDeviceManagementManagedDevice -Filter "userId eq '$userId'" -All
    if (-not $devices -or $devices.Count -eq 0) {
      return ,([pscustomobject]@{ UserUPN=$UserPrincipalName; DevicesChecked=0; MobilesFound=0; Mode=$Mode; Timestamp=(Get-Date) }),
             ([pscustomobject]@{ UserUPN=$UserPrincipalName; DeviceId=$null; DeviceName=$null; OperatingSystem=$null; Action=$null; Status='NoDevices'; Detail='No devices for this user'; Timestamp=(Get-Date) })
    }

    $mobile = $devices | Where-Object { Is-MobileOs $_.OperatingSystem }
    if (-not $mobile -or $mobile.Count -eq 0) {
      return ,([pscustomobject]@{ UserUPN=$UserPrincipalName; DevicesChecked=$devices.Count; MobilesFound=0; Mode=$Mode; Timestamp=(Get-Date) }),
             ([pscustomobject]@{ UserUPN=$UserPrincipalName; DeviceId=$null; DeviceName=$null; OperatingSystem=$null; Action=$null; Status='NoMobileDevices'; Detail='Only non-mobile devices present'; Timestamp=(Get-Date) })
    }

    $summary = [pscustomobject]@{ UserUPN=$UserPrincipalName; DevicesChecked=$devices.Count; MobilesFound=$mobile.Count; Mode=$Mode; Timestamp=(Get-Date) }
    $rows = New-Object System.Collections.ArrayList

    foreach ($d in $mobile) {
      $row = [pscustomobject]@{
        UserUPN         = $UserPrincipalName
        DeviceId        = $d.Id
        DeviceName      = $d.DeviceName
        OperatingSystem = $d.OperatingSystem
        ManagementState = $d.ManagementState
        Action          = $Mode
        Status          = $null
        Detail          = $null
        Timestamp       = (Get-Date)
      }
      try {
        if (Is-AlreadyDone -Device $d) {
          $row.Status = 'Skipped'; $row.Detail = "Already retired/wiped/pending (state: $($d.ManagementState))"
        } else {
          $targetText = "$($Mode) '$($d.DeviceName)' (OS=$($d.OperatingSystem))"
          if ($PSCmdlet.ShouldProcess($d.DeviceName,$targetText)) {
            if ($Mode -eq 'Retire') { Invoke-MgDeviceManagementManagedDeviceRetire -ManagedDeviceId $d.Id }
            else { Remove-MgDeviceManagementManagedDevice -ManagedDeviceId $d.Id }
            $row.Status = 'Success'; $row.Detail = "$Mode invoked"
          } else {
            $row.Status = 'WhatIf'; $row.Detail = 'Action not executed due to -WhatIf'
          }
        }
      } catch {
        $row.Status = 'Error'; $row.Detail = $_.Exception.Message
      }
      [void]$rows.Add($row)
    }

    Write-Output $summary
    Write-Output $rows
  }
}

# --- Connect to Microsoft Graph (non-prod default: interactive) ---
try {
  Import-Module Microsoft.Graph -ErrorAction SilentlyContinue
  if (-not (Get-MgContext)) {
    Connect-MgGraph -Scopes @('DeviceManagementManagedDevices.ReadWrite.All','User.Read.All','Device.Read.All') -ErrorAction Stop | Out-Null
  }
  Select-MgProfile -Name 'v1.0' -ErrorAction SilentlyContinue | Out-Null
} catch {
  Write-Warning "Graph connection failed: $($_.Exception.Message)"
  throw
}

# --- Invoke Intune cleanup for the offboarded user ---
try {
  Write-Step "[Intune] Starting mobile cleanup for $userUPN (Mode=Retire, WhatIf=$($IntuneDryRun.IsPresent))"
  $intuneResult = Remove-IntuneMobileDevicesForUser -UserPrincipalName $userUPN -Mode Retire -WhatIf:$IntuneDryRun -Confirm:$false
  $summary = $intuneResult | Where-Object { $_.PSObject.Properties.Name -contains 'DevicesChecked' }
  if ($summary) {
    Write-Step ("[Intune] MobilesFound={0} Mode={1}" -f $summary.MobilesFound, $summary.Mode)
  }
  $rows = $intuneResult | Where-Object { $_.PSObject.Properties.Name -contains 'DeviceId' }
  foreach ($r in $rows) {
    Write-Host ("[Intune] {0} {1} ({2}) -> {3} {4}" -f $r.Action, $r.DeviceName, $r.OperatingSystem, $r.Status, $r.Detail)
  }
} catch {
  Write-Warning "[Intune] Cleanup error: $($_.Exception.Message)"
}

# ---------------------- SUMMARY ----------------------
[pscustomobject]@{
  UserSam         = $userSam
  UPN             = $userUPN
  DisabledNow     = -not $user.Enabled
  GroupsCsv       = $csvPath
  TargetOU        = $TargetDisabledOU
  IntuneDryRun    = $IntuneDryRun.IsPresent
  Timestamp       = (Get-Date)
} | Format-List
