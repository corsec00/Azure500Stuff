#Get Logged into Azure
Add-AzureRmAccount

#Create the resource group
$ResourceGroup = "AZUG"
$Location = "eastus"

New-AzureRmResourceGroup -Name $ResourceGroup -Location $Location

#Create an alias since YOU are LAZY
New-Alias -Name azd -Value New-AzureRmResourceGroupDeployment

#Hello World Demo
New-AzureRmResourceGroupDeployment -Name "Hello-World" -ResourceGroupName $ResourceGroup -TemplateFile .\HelloWorld.json

#Parameter Demo
New-AzureRmResourceGroupDeployment -Name "Parameter-Example" -ResourceGroupName $ResourceGroup -TemplateFile .\ParameterExamples.json

#Create a Parameter Object
$templateParameters = @{
    stringParam = "My string"
    intParam = 4
    arrayParam = @(1,2,3,4)
}

Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroup -TemplateFile .\ParameterExamples.json -TemplateParameterObject $templateParameters

New-AzureRmResourceGroupDeployment -Name "Parameter-Example" -ResourceGroupName $ResourceGroup -TemplateFile .\ParameterExamples.json `
    -TemplateParameterObject $templateParameters

$templateParameters = @{
    stringParam = "option 2"
    intParam = 3
    arrayParam = @(1,2,3,4)
}

New-AzureRmResourceGroupDeployment -Name "Parameter-Example" -ResourceGroupName $ResourceGroup -TemplateFile .\ParameterExamples.json `
    -TemplateParameterObject $templateParameters

#Variables Demo
New-AzureRmResourceGroupDeployment -Name "Variable-Example" -TemplateFile .\VariableExamples.json -ResourceGroupName $ResourceGroup

#Function Demo
New-AzureRmResourceGroupDeployment -Name "Function-Example" -TemplateFile .\FunctionExample.json -ResourceGroupName $ResourceGroup

#Resources Demo
$vmCredential = Get-Credential -UserName "azugAdmin" -Message "Password for new VM"
###
$templateParameters = @{
    virtualMachineSize = "Standard_D2_v3"
    adminUsername = $vmCredential.UserName
    adminPassword = $vmCredential.Password
    storageAccountType = "Standard_LRS"
}

New-AzureRmResourceGroupDeployment -Name "Basic-VM" -ResourceGroupName $ResourceGroup -TemplateFile .\101-1vm-2nics-2subnets-1vnet.json -TemplateParameterObject $templateParameters

#Nested Templates demo
New-AzureRmResourceGroupDeployment -Name "NestedInline" -ResourceGroupName $ResourceGroup -TemplateFile .\NestedTemplateInline.json

Set-Location NestedTemplateExample

$templateParameters = @{
    VMSize = "S"
    adminUsername = $vmCredential.UserName
    adminPassword = $vmCredential.Password
    dnsLabelPrefix = "azugexample"
}

Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroup -TemplateFile .\master.json -TemplateParameterObject $templateParameters

New-AzureRmResourceGroupDeployment -Name "LinkedTemplate" -ResourceGroupName $ResourceGroup -TemplateFile .\master.json -TemplateParameterObject $templateParameters

$templateParameters.VMSize = "M"

New-AzureRmResourceGroupDeployment -Name "LinkedTemplate" -ResourceGroupName $ResourceGroup -TemplateFile .\master.json -TemplateParameterObject $templateParameters -Mode Incremental

#Cleanup after yourself, don't be a SLOB
Remove-AzureRmResourceGroup -Name $ResourceGroup -Force:$true

