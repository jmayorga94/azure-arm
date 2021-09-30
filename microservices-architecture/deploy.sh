slot=$1
timestamp=`date "+%Y%m%d-%H%M%S"`
resourceGroup=rg-workspacemgmt-dev 
resourceGroupShared=rg-shared-dev
az group create --location eastus --name $resourceGroupShared --tags "Project":"WorkspaceManagement", "Environment":"Dev"
az group create --location eastus --name $resourceGroup --tags "Project":"WorkspaceManagement", "Environment":"Dev"
az deployment group create -g $resourceGroupShared --template-file acr-vnet/acr-vnetTemplate.json  -n "acr-vnet-${timestamp}"
az deployment group create -g $resourceGroup --template-file aks/aks.json --parameters aks/parameters.json -n "aks-${timestamp}"
az deployment group create -g $resourceGroup --template-file servicebus/servicebusTemplate.json --parameters servicebus/parameters.json -n "servicebus-${timestamp}"
az deployment group create -g $resourceGroup --template-file sql-database/sqltemplate.json --parameters Sql-Database/parameters.json      -n "sql-database-${timestamp}"
 az aks update -n aks-dev-workspacemngmt  -g rg-workspacemgmt-dev  --attach-acr crdevelopmenteastus001