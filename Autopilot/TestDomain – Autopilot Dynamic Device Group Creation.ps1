# ---------------------------------------------
# Connect to Microsoft Graph
# Required for creating dynamic device groups
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

# ---------------------------------------------
# Create the dynamic device group
# ---------------------------------------------
New-MgGroup -DisplayName $GroupName `
            -Description $GroupDescription `
            -MailEnabled:$false `
            -MailNickname $GroupName `
            -SecurityEnabled:$true `
            -GroupTypes "DynamicMembership" `
            -MembershipRule $DynamicRule `
            -MembershipRuleProcessingState "On"
