$ArmEndpoint = "https://adminmanagement.local.azurestack.external"
$endpoints = Invoke-RestMethod -Method Get -Uri "$($ArmEndpoint.TrimEnd('/'))/metadata/endpoints?api-version=2015-01-01" -Verbose
$aadAuthorityEndpoint = $endpoints.authentication.loginEndpoint
$aadResource = $endpoints.authentication.audiences[0]
$AadTenantId = "anexinetasp.onmicrosoft.com"

$token = Get-AzureStackToken -Authority $aadAuthorityEndpoint -AadTenantId $AadTenantId -Resource $aadResource

#Create Product Request
Add-AzureRMEnvironment `
    -Name "AzureStackAdmin" `
    -ArmEndpoint $ArmEndpoint

Add-AzureRmAccount -Environment "AzureStackAdmin" -Credential $AzureStackAdmin

$tokens = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.TokenCache.ReadItems()

$subID = (Get-AzureRmSubscription).Id
$ActivationResourceGroup = "azurestack-activation"
$apiVersion = "2016-01-01"
$uri = $ArmEndpoint + "/subscriptions/" + $subID + "/resourceGroups/" + $ActivationResourceGroup + "/providers/Microsoft.AzureBridge.Admin/activations/default/products?api-version=" + $apiVersion
$response = Invoke-RestMethod -Method Get -Uri $uri -Headers @{'Authorization'="Bearer $token"}

$MPItems = Get-AzureRmResource -ResourceId "/subscriptions/$subID/resourceGroups/$ActivationResourceGroup/providers/Microsoft.AzureBridge.Admin/activations/default/products/"

$downloadUri = $ArmEndpoint + $MPItem.ResourceId + "/download?api-version=$apiVersion"
$downloadResponse = Invoke-RestMethod -Method Post -Uri $downloadUri -Headers @{'Authorization'="Bearer $($tokens.AccessToken)"}

$MPItemResourceID = "/subscriptions/$subID/resourceGroups/$ActivationResourceGroup/providers/Microsoft.AzureBridge.Admin/activations/default/downloadedproducts/" + $MPItem.Properties.publisherIdentifier + "." + $MPItem.Properties.offer + $MPItem.Properties.sku


$downloadItem = Get-AzureRmResource -ResourceId $MPItemResourceID
$downloadItem.Properties.provisioningState