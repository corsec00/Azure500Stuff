<#
.SYNOPSIS
    Contains functions to view and download available products from the Azure Syndication
    Requires that the Azure Stack system already be registered and syndicated with Azure
#>
function Get-AzSMarketplaceItem {
[CmdletBinding(DefaultParameterSetName='MarketplaceItemName')]    

    Param(
        [Parameter(Mandatory=$true, ParameterSetName='MarketplaceItemName')]
        [ValidateNotNullorEmpty()]
        [string] $MarketplaceItemName,

        [Parameter(Mandatory=$true, ParameterSetName='MarketplaceItemID')]
        [ValidateNotNullorEmpty()]
        [string] $MarketplaceItemID,

        [Parameter(Mandatory=$false, ParameterSetName='MarketplaceItemName')]
        [Parameter(Mandatory=$false, ParameterSetName='MarketplaceItemID')]
        [ValidateNotNullorEmpty()]
        [string] $ActivationResourceGroup = "azurestack-activation",

        [Parameter(Mandatory=$true, ParameterSetName='MarketplaceItemName')]
        [Parameter(Mandatory=$true, ParameterSetName='MarketplaceItemID')]
        [Parameter(Mandatory=$true, ParameterSetName='RetrieveAll')]
        [ValidateNotNullorEmpty()]
        [string] $SubscriptionID,

        [Parameter(Mandatory=$true, ParameterSetName='RetrieveAll')]
        [bool] $ListAll
    )


    $MPItems = Get-AzureRmResource -ResourceId "/subscriptions/$SubscriptionID/resourceGroups/$ActivationResourceGroup/providers/Microsoft.AzureBridge.Admin/activations/default/products/"
    
    if($MarketplaceItemName){
        $MPItems = $MPItems | Where-Object{$_.Properties.displayName -eq $MarketplaceItemName}
        return $MPItems
    }elseif ($MarketplaceItemID) {
        $MPItems = $MPItems | Where-Object{$_.Properties.galleryItemIdentity -eq $MarketplaceItemID}
        return $MPItems
    }elseif($ListAll) {
        return $MPItems
    }
}

function Add-AzSMarketplaceItem {
[CmdletBinding(DefaultParameterSetName='MarketplaceItemName')]

    Param(
        [Parameter(Mandatory=$true, ParameterSetName='MarketplaceItemName')]
        [ValidateNotNullorEmpty()]
        [string] $MarketplaceItemName,

        [Parameter(Mandatory=$true, ParameterSetName='MarketplaceItemID')]
        [ValidateNotNullorEmpty()]
        [string] $MarketplaceItemID,

        [Parameter(Mandatory=$true, ParameterSetName='MarketplaceItemName')]
        [Parameter(Mandatory=$true, ParameterSetName='MarketplaceItemID')]
        [ValidateNotNullorEmpty()]
        [string] $SubscriptionID,

        [Parameter(Mandatory=$true, ParameterSetName='MarketplaceItemName')]
        [Parameter(Mandatory=$true, ParameterSetName='MarketplaceItemID')]
        [ValidateNotNullorEmpty()]
        [string] $apiVersion = "2016-01-01",

        [Parameter(Mandatory=$true, ParameterSetName='MarketplaceItemName')]
        [Parameter(Mandatory=$true, ParameterSetName='MarketplaceItemID')]
        [ValidateNotNullorEmpty()]
        [string] $ArmEndpoint = "https://adminmanagement.local.azurestack.external",

        [Parameter(Mandatory=$false, ParameterSetName='MarketplaceItemName')]
        [Parameter(Mandatory=$false, ParameterSetName='MarketplaceItemID')]
        [bool] $BackgroundDownload
    )

    if($MarketplaceItemName){
        $MPItem = Get-AzSMarketplaceItem -MarketPlaceItemName $MarketplaceItemName -SubscriptionID $SubscriptionID
    }elseif($MarketplaceItemID){
        $MPItem = Get-AzSMarketplaceItem -MarketPlaceItemID $MarketplaceItemID -SubscriptionID $SubscriptionID
    }else{
        throw("No marketplace item name or ID specified")
    }
    if(-not $MPItem){
        throw("No marketplace item found with matching Name or ID")
    }

   # Retrieve the access token
   $azureEnvironment = Get-AzureRmEnvironment -Name "AzureCloud"
   $tokens = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.TokenCache.ReadItems()
   #This process needs to be validated
   $token = $tokens | Where-Object Resource -EQ $azureEnvironment.ActiveDirectoryServiceEndpointResourceId | Where-Object DisplayableId -EQ $azureAccount.Context.Account.Id | Sort-Object ExpiresOn | Select-Object -Last 1

    if(-not $token){
        throw("No authorization token found for Azure Stack Admin.  Please log in to Azure Stack Admin first")
    }

    $downloadUri = $ArmEndpoint + $MPItem.ResourceId + "/download?api-version=$apiVersion"
    $response = Invoke-RestMethod -Method Post -Uri $downloadUri -Headers @{'Authorization'="Bearer $($token.AccessToken)"}

    #Check to see if response is good.  If not throw an error
    if($response.Status -gt 302){
        throw("Error requesting the Marketplace Item $($MPItem.Properties.displayName)\n REST respoonse was $($response.Status)")
    }
    if(-not $BackgroundDownload){
        $MPItemResourceID = "/subscriptions/$subID/resourceGroups/$ActivationResourceGroup/providers/Microsoft.AzureBridge.Admin/activations/default/downloadedproducts/" + $MPItem.Properties.publisherIdentifier + "." + $MPItem.Properties.offer + $MPItem.Properties.sku

    
        do{
            $downloadItem = Get-AzureRmResource -ResourceId $MPItemResourceID
            Write-Output "Downloading Item: $($MPItem.Properties.displayName)"
        }while($downloadItem.provisioningState -ne "Succeeded")
    }
    else{
        Write-Output "Downloading Item: $($MPItem.Properties.displayName) in background.  Check portal for confirmation."
    }

}