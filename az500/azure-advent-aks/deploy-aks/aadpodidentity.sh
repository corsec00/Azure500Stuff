
#Get the AKS context
az aks get-credentials -g advent-aks -n advent-aks

#Deploy the Managed Idenity Controller and Node Managed Identity
kubectl apply -f https://raw.githubusercontent.com/Azure/aad-pod-identity/master/deploy/infra/deployment-rbac.yaml

#Install and bind the Azure Identity
kubectl apply -f ./yaml_files/aadpodidentity.yaml
kubectl apply -f ./yaml_files/aadpodidentitybinding.yaml

#Deploy the python app from secrets-app directory
kubectl apply -f ./deployment.yaml

response=$(curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' -H Metadata:true -s)
access_token=$(echo $response | python -c 'import sys, json; print (json.load(sys.stdin)["access_token"])')
curl https://<VAULT_NAME>.vault.azure.net/secrets/everything?api-version=2016-10-01 -H "Authorization: Bearer $access_token"