param location string = resourceGroup().location


module database 'modules/database.bicep' = {
  name: 'database'
  params: {
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: 'name'
  location: location
  properties: {
    sku: {
      name: 'Free'
    }
  }
}
