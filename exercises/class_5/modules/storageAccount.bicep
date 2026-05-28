@description('The region to deploy the resources.')
param location string = resourceGroup().location
param staPrefix string = 'learntv'

var staName = '${staPrefix}${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2024-05-01' = {
  name: staName
  location: location
  sku: {
    name: 'Premium_LRS'
  }
  kind: 'StorageV2'
}

