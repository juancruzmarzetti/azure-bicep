param cosmosDBAccountName string = 'toyrnd1-${uniqueString(resourceGroup().id)}'
param cosmosDBThroghput int = 400
param location string = resourceGroup().location

var cosmosDBDabatabseName = 'FlightTests'
var cosmosDBContainerName = 'FlightTestsContainer'
var cosmosDBContainerPartitionKey = '/droneId'
var logAnalyticsWorkspaceName = 'ToyLogs'
var cosmosDBAccountDiagnosticSettingsName = 'route-logs-to-log-analytics'

resource cosmosDBAccount 'Microsoft.DocumentDB/databaseAccounts@2021-04-15' = {
  name: cosmosDBAccountName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
      }
    ]
  }
}

// Child resource declaration using the parent property approach.
resource cosmosDBDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-04-15' = {
  name: cosmosDBDabatabseName
  parent: cosmosDBAccount
  properties: {
    resource: {
      id: cosmosDBDabatabseName
    }
    options: {
      throughput: cosmosDBThroghput
    }
  }

  // Child resource declaration using the nesting approach --> inherits parent's API version and type.
  resource container 'containers' = {
    name: cosmosDBContainerName
    properties: {
      resource: {
        id: cosmosDBContainerName
        partitionKey: {
          paths: [
            cosmosDBContainerPartitionKey
          ]
          kind: 'Hash'
        }
      }
      options: {}
    }
  }
}

// We reference an existing logAnalyticsWorkspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01-preview' existing = {
  name: logAnalyticsWorkspaceName // same name as the one already created
}

resource cosmosDBAccountDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: cosmosDBAccountDiagnosticSettingsName
  scope: cosmosDBAccount // using the scope property approach to set the diagnostic settings as an extension of the cosmosDBAccount resource
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'DataPlaneRequests'
        enabled: true
      }
    ]
  }
}

