param location string = resourceGroup().location

// Example of use of conditions in modules. If logAnalyticsWorkspaceId is not an empty string, 
// the diagnostics settings for the Cosmos DB account will be deployed, 
// otherwise they will be skipped. This allows for more flexible deployments 
// based on the presence of certain parameters.
@description('if a logAnalyticsWorkspaceId is defined, cosmosDBAccountDiagnostics are deployed')
param logAnalyticsWorkspaceId string = ''

resource cosmosDBAccount 'Microsoft.DocumentDB/databaseAccounts@2021-07-01-preview' = {
  name: 'name'
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Eventual'
      maxStalenessPrefix: 1
      maxIntervalInSeconds: 5
    }
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: true
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
    capabilities: [
      {
        name: 'EnableTable'
      }
    ]
  }
}

resource cosmosDBAccountDiagnostics 'Microsoft.DocumentDB/databaseAccounts/diagnosticSettings@2021-05-01-preview' = if (logAnalyticsWorkspaceId != '') {
  scope: cosmosDBAccount
  name: 'route-logs-to-log-analytics/${cosmosDBAccount.name}'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'DataPlaneRequests'
        enabled: true
      }
    ]
  }
}
