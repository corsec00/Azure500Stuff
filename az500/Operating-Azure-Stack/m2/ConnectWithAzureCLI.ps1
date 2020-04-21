az cloud register -n "azurestackadmin" --endpoint-resource-manager "https://adminmanagement.local.azurestack.external" --suffix-storage-endpoint "local.azurestack.external" --suffix-keyvault-dns ".adminvault.local.azurestack.external"

az cloud set -n "azurestackadmin"

az cloud update --profile 2019-03-01-hybrid

az login -u "username@tenantname.onmicrosoft.com" --tenant "tenantname.onmicrosoft.com"

az group list