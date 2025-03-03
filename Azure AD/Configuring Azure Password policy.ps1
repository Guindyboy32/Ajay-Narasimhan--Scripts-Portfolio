# Define password policy details
$PolicyName = "DefaultPasswordPolicy"
$EnforceComplexity = $true
$PasswordLength = 12
$PasswordValidityPeriod = 90
$PasswordHistoryCount = 24

# Create and configure password policy
New-AzureADMSPasswordSingleSignOnSettings -DisplayName $PolicyName -ComplexityEnabled $EnforceComplexity -MinLength $PasswordLength -ValidityPeriod $PasswordValidityPeriod -HistoryCount $PasswordHistoryCount
