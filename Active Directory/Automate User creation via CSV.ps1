# Variables
$csvPath = "C:\\Users.csv"
$ou = "OU=Users,DC=domain,DC=com"

# Import CSV and Create Users
Import-Csv -Path $csvPath | ForEach-Object {
    New-ADUser -Name $_.Name -GivenName $_.FirstName -Surname $_.LastName -SamAccountName $_.SamAccountName -UserPrincipalName "$($_.SamAccountName)@domain.com" -Path $ou -AccountPassword (ConvertTo-SecureString $_.Password -AsPlainText -Force) -Enabled $true
}
