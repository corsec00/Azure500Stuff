az aks nodepool add --resource-group GROUP_NAME --cluster-name CLUSTER_NAME --name NODEPOOL_NAME --node-count 1 --node-vm-size Standard_D64s_v3 --node-zones 1

az vmss deallocate -g MC_AKS_RESOURCE_GROUP -n NODEPOOL__VMSS_NAME

az vmss update -g MC_AKS_RESOURCE_GROUP -n NODEPOOL__VMSS_NAME --set additionalCapabilities.ultraSSDEnabled=true

az vmss start -g MC_AKS_RESOURCE_GROUP-n NODEPOOL__VMSS_NAME

az disk create -g MC_AKS_RESOURCE_GROUP--name ultraSSD --size-gb 1024 --zone 1 --sku UltraSSD_LRS --disk-iops-read-write 160000 --disk-mbps-read-write 2000

az disk delete -g MC_AKS_RESOURCE_GROUP--name ultraSSD