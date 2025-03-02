# Get all licensed users
Get-MsolUser -All | Where-Object { $_.isLicensed -eq $true } | Select-Object DisplayName, UserPrincipalName, Licenses
