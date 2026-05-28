param location string = resourceGroup().location
param appServiceAppName string
param environmentType string

var tags = {
  environmentType: environmentType
}

resource webApplication 'Microsoft.Web/sites@2023-12-01' = {
  name: '${appServiceAppName}-app'
  location: location
  tags: tags
  properties: {
    serverFarmId: webServerFarm.id
  }
}

resource webServerFarm 'Microsoft.Web/serverFarms@2023-12-01' = {
  name: appServiceAppName
  location: location
  tags: tags
  kind: 'linux'
  sku: {
    name: 'F1'
  }
}
