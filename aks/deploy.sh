slot=$1
timestamp=`date "+%Y%m%d-%H%M%S"`
resourceGroup=rg-workspacemgmt-dev-001 
az deployment group create -g $resourceGroup --template-file aksTemplate.json --parameters parameters.json -n "aks-${timestamp}"