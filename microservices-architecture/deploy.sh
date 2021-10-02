slot=$1
EnvironmentValue="QA"
timestamp=`date "+%Y%m%d-%H%M%S"`
resourceGroup=rg-workspacemgmt-$EnvironmentValue 
resourceGroupShared=rg-shared-$EnvironmentValue
locationValue="eastus"
ProjectValue="WorkspaceManagement"
registryName="crqaeastus001"
aksName="aks-qa-workspacemgmt"
subscriptionNameOrId=""
servicePrincipalName="crqaeastus001-service-principal"
registryId=$(az acr show --name $registryName --query id --output tsv)
#View subscriptions
az account list --output table

#Set subscription
az account set --subscription $subscriptionNameOrId

az group create --location $locationValue --name $resourceGroupShared --tags "Project":$ProjectValue, "Environment":$EnvironmentValue
az group create --location $locationValue --name $resourceGroup --tags "Project":$ProjectValue, "Environment":$EnvironmentValue

#Vnet Deployment
az deployment group create -g $resourceGroupShared --template-file vnet/vnetTemplate.json --parameters vnet/vnet.parameters.json  -n "vnet-${timestamp}"

#ACR Deployment
az deployment group create -g $resourceGroupShared --template-file acr/acrTemplate.json --parameters acr/acr.parameters.json -n "acr-${timestamp}"

#AKS Deployment
az deployment group create -g $resourceGroup --template-file aks/aksTemplate.json --parameters aks/aks.parameters.json -n "aks-${timestamp}"

#ServiceBus Deployment
az deployment group create -g $resourceGroup --template-file servicebus/servicebusTemplate.json --parameters servicebus/servicebus.parameters.json -n "servicebus-${timestamp}"

#SQL Deployment Deployment
az deployment group create -g $resourceGroup --template-file sql-database/sqltemplate.json --parameters Sql-Database/sql.parameters.json      -n "sql-database-${timestamp}"

#Attach AKS to Azure Container Registry
az aks update -n $aksName  -g $resourceGroup  --attach-acr $registryName

#Create service principal for ACR authentication (pulling and pushing images)
sp_psswd=$(az ad sp create-for-rbac --name $servicePrincipalName --scopes $registryId --role acrpush --query password -o tsv)
sp_appId=$(az ad sp list --display-name $servicePrincipalName --query '[].appId' -o tsv)

echo "Service principal ID: $sp_appId"
echo "Service principal password: $sp_psswd"