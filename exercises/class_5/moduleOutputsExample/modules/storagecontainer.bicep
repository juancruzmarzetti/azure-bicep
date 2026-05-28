param location string = resourceGroup().location

resource storageAccount 'Microsoft.Storage/storageAccounts@2024-05-01' = {
  name: 'name'
  location: location
  sku: {
    name: 'Premium_LRS'
  }
  kind: 'StorageV2'

  resource blobService 'blobServices' existing = {
    name: 'default'

    resource container 'containers' = {
      name: 'mycontainer'
    }
  }
}

output blobContainerResourceId string = storageAccount::blobService::container.id
