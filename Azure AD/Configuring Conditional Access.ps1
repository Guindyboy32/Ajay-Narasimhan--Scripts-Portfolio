# Define policy details
$PolicyName = "DefaultPolicy"
$UserGroup = "All Users"
$Condition = "All Applications"

# Create a conditional access policy
New-AzureADMSConditionalAccessPolicy -DisplayName $PolicyName -State "Enabled" -Conditions @{
    Users = @{
        IncludeUsers = @("All")
    }
    Applications = @{
        IncludeApplications = @("All")
    }
}
