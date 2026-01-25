param storageAccountName string = 'toylaunch${uniqueString(resourceGroup().id)}'
param appServiceAppName string = 'toylaunch${uniqueString(resourceGroup().id)}'
param location string = 'eastus'

//Supporting non-productive envirionments:
@allowed([
  'nonprod'
  'prod'
])
param environmentType string
var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

module app 'appService.bicep' = {
  name: 'app'
  params: {
    appServiceAppName: appServiceAppName
    location: location
    environmentType: environmentType
  }
}

//Outputs:
output appServiceAppHostname string = app.outputs.appServiceAppHostname

/*
Tu execute it USING Azure CLI:

  az deployment group create /
    --name main /
    --template-file main.bicep /
    --parameters environmentType=nonprod

*/

