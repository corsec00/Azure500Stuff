#Log into Azure Public Cloud
Add-AzureRmAccount -EnvironmentName AzureCloud

#Create a custom role for the registration process if desired
#Make sure to update the Subscription ID in the json file first
New-AzureRmRoleDefinition -InputFile azurestack_registration_role.json

#Assign an account to the role
New-AzureRmRoleAssignment -ObjectId "USER_ID" -RoleDefinitionName "Azure Stack registration role"

#Enable the Azure Stack provider on your subscription
Get-AzureRmSubscription -SubscriptionName "Azure_Sub_Name" | Select-AzureRmSubscription
Register-AzureRmResourceProvider -ProviderNamespace Microsoft.AzureStack

#Navigate to the Azure Stack tools registration director
Set-Location -Path C:\AzureStack-Tools-master\Registration
Import-Module .\RegisterWithAzure.psm1

#Thanks to Matt McSpirit for this part
$runTime = $(Get-Date).ToString("MMddyy-HHmmss")
$asdkHostName = ($env:computername).ToLower()
$asdkRegName = "asdkreg-$asdkHostName-$runTime"

$cloudAdminUsername = "azurestack\cloudadmin"
$cloudAdminCreds = Get-Credential -UserName $cloudAdminUsername -Message "Enter the cloud domain credentials to access the privileged endpoint."
Set-AzsRegistration -PrivilegedEndpointCredential $cloudAdminCreds `
    -PrivilegedEndpoint AzS-ERCS01 -RegistrationName "$asdkRegName" `
    -BillingModel Development -ErrorAction Stop
