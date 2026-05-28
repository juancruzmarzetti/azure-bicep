@description('Name of the app service plan')
param appServiceAppName string

@description('Type of environment to deploy the app service plan to.')
@allowed([
  'development'
  'production'
])
param environmentType string = 'production'
param location string = resourceGroup().location

module sta 'modules/storageAccount.bicep' = {
  name: 'storageAccount'
}

module app 'modules/app.bicep' = {
  name: 'app'
  params: {
    location: location
    appServiceAppName: appServiceAppName
    environmentType: environmentType
  }
}
