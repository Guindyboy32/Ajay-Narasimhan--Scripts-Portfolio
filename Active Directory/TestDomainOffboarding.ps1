<#
TestDomainOffboarding.ps1
1) Disable account
2) Scramble password
3) Snapshot groups -> CSV
4) Remove all direct groups EXCEPT those matching -KeepGroupsPattern (default: Domain Users)
5) Hide from address lists (msExchHideFromAddressLists = $true)
6) Move to: OU=Inactive,DC=TestDomain,DC=local
#>

[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
param(
  [Parameter(Mandatory=$true)][string]$UserId,                    # sAM or UPN
  [string]$EvidencePath = $env:TEMP,                              # where CSV is saved
  [string]$TargetDisabledOU = 'OU=Inactive,DC=TestDomain,DC=local',
  [int]$PasswordLength = 24,
  [string]$KeepGroupsPattern = '^Domain Users$'                   # groups to KEEP (regex)
)

$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory -ErrorAction Stop

function Resolve-User {
  param([string]$Id)
  if ($Id -like '*@*') {
    Get-ADUser -Filter "UserPrincipalName -eq '$Id'" -Properties UserPrincipalName,SamAccountName,DistinguishedName,Enabled
  } else {
    Get-ADUser -Identity $Id -Properties UserPrincipalName,SamAccountName,DistinguishedName,Enabled
  }
}

function New-RandomPassword {
  param([int]$Length = 24)
  $upper = 65..90 | ForEach-Object {[char]$_}
  $lower = 97..122 | ForEach-Object {[char]$_}
  $digits = 48..57 | ForEach-Object {[char]$_}
  $symbols = '!','@','#','$','%','^','&','*','-','_','+','=','?'
  $all = $upper + $lower + $digits + $symbols
  $pw = @()
  $pw += ($upper | Get-Random); $pw += ($lower | Get-Random)
  $pw += ($digits | Get-Random); $pw += ($symbols | Get-Random)
  for ($i = $pw.Count; $i -lt $Length; $i++) { $pw += ($all | Get-Random) }
  -join ($pw | Sort-Object {Get-Random})
}

try {
  $user = Resolve-User -Id $UserId
  if (-not $user) { throw "User '$UserId' not found." }

  $userSam = [string]$user.SamAccountName
  $userUPN = [string]$user.UserPrincipalName
  $userDN  = [string]$user.DistinguishedName

  Write-Verbose "User: $userSam | DN: $userDN | Enabled: $($user.Enabled)"
  Write-Verbose "Target OU: $TargetDisabledOU"

  # 1) Disable
  if ($user.Enabled -eq $true) {
    if ($PSCmdlet.ShouldProcess($userSam, "Disable-ADAccount")) {
      Disable-ADAccount -Identity $userDN -Confirm:$false
      Write-Host "[1/6] Disabled account"
    }
  } else { Write-Host "[1/6] Already disabled" }

  # 2) Scramble password
  if ($PSCmdlet.ShouldProcess($userSam, "Reset password to random value")) {
    $newPlain = New-RandomPassword -Length $PasswordLength
    $secure   = ConvertTo-SecureString -String $newPlain -AsPlainText -Force
    Set-ADAccountPassword -Identity $userDN -Reset -NewPassword $secure -Confirm:$false
    Write-Host "[2/6] Password scrambled"
  }

  # 3) Snapshot groups -> CSV (token-based membership; primary group not included)
  $ts          = Get-Date -Format 'yyyyMMdd-HHmmss'
  $evidenceDir = (New-Item -Path $EvidencePath -ItemType Directory -Force).FullName
  $csvPath     = Join-Path $evidenceDir "$($userSam)-groups-$ts.csv"

  $snap = Get-ADPrincipalGroupMembership -Identity $userDN | Sort-Object Name
  $snap | Select-Object @{n='SamAccountName';e={$userSam}},
                        @{n='GroupName';e={$_.Name}},
                        GroupCategory |
         Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
  Write-Host "[3/6] Group snapshot saved: $csvPath"

  # 4) Remove ALL direct groups except those matching KeepGroupsPattern
  #    Use memberOf (direct only) so Remove-ADGroupMember won't fail on nested memberships.
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

  # 5) Hide from address lists
  if ($PSCmdlet.ShouldProcess($userSam, "Set msExchHideFromAddressLists = TRUE")) {
    try {
      Set-ADUser -Identity $userDN -Replace @{ 'msExchHideFromAddressLists' = $true } -Confirm:$false
      Write-Host "[5/6] Hidden from address lists"
    } catch {
      Write-Warning "Set msExchHideFromAddressLists failed: $($_.Exception.Message)"
    }
  }

  # 6) Move to Inactive OU
  if ($userDN -notmatch [regex]::Escape($TargetDisabledOU)) {
    if ($PSCmdlet.ShouldProcess($userSam, "Move-ADObject to $TargetDisabledOU")) {
      Move-ADObject -Identity $userDN -TargetPath $TargetDisabledOU -Confirm:$false
      Write-Host "[6/6] Moved to Inactive OU"
    }
  } else { Write-Host "[6/6] Already in Inactive OU" }

  [pscustomobject]@{
    UserSam           = $userSam
    UPN               = $userUPN
    GroupsCsv         = $csvPath
    DisabledNow       = $true
    HiddenFromAL_AD   = $true
    MovedToInactiveOU = $true
  } | Write-Output

} catch {
  Write-Error $_.Exception.Message
  exit 1
}


