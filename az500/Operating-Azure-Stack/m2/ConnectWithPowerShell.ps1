#Remove existing versions of Azure Stack PowerShell modules
Get-Module -Name Azs.* -ListAvailable | Uninstall-Module -Force -Verbose
Get-Module -Name Azure* -ListAvailable | Uninstall-Module -Force -Verbose

#Install for Azure Stack 1904 and after
Install-Module -Name AzureRM.BootStrapper

Use-AzureRmProfile -Profile 2019-03-01-hybrid -Force
Install-Module -Name AzureStack -RequiredVersion 1.7.2

#Install for Azure Stack 1903 and earlier
Install-Module -Name AzureRM -RequiredVersion 2.4.0
Install-Module -Name AzureStack -RequiredVersion 1.7.1

#Check installation Process
Get-Module -Name "Azure*" -ListAvailable
Get-Module -Name "Azs*" -ListAvailable

#Install AzureStack-Tools

# Change directory to the root directory. 
cd \

# Download the tools archive.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 
invoke-webrequest `
  https://github.com/Azure/AzureStack-Tools/archive/master.zip `
  -OutFile master.zip

# Expand the downloaded files.
expand-archive master.zip `
  -DestinationPath . `
  -Force

# Register an Azure Resource Manager environment that targets your Azure Stack instance. Get your Azure Resource Manager endpoint value from your service provider.
Add-AzureRMEnvironment -Name "AzureStackAdmin" -ArmEndpoint "https://adminmanagement.local.azurestack.external" `
  -AzureKeyVaultDnsSuffix adminvault.local.azurestack.external `
  -AzureKeyVaultServiceEndpointResourceId https://adminvault.local.azurestack.external

# Set your tenant name
$AuthEndpoint = (Get-AzureRmEnvironment -Name "AzureStackAdmin").ActiveDirectoryAuthority.TrimEnd('/')
$AADTenantName = "<myDirectoryTenantName>.onmicrosoft.com"
$TenantId = (invoke-restmethod "$($AuthEndpoint)/$($AADTenantName)/.well-known/openid-configuration").issuer.TrimEnd('/').Split('/')[-1]

# Sign in to the environment
Add-AzureRmAccount -EnvironmentName "AzureStackAdmin" -TenantId $TenantId

#Test connection
Get-AzureRmResourceGroup -Location "Local"