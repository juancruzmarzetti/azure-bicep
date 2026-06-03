param location string = resourceGroup().location

@secure()
param sqlAdministratorLogin string
@secure()
param sqlAdministratorPassword string

@description('The role definition ID of the role to assign to the managed identity. Contributor role as default.')
param contributorRoleDefinitionId string = 'b24988ac-6180-42a0-ab88-20f7382dd24'
param managedIdentityName string = guid(contributorRoleDefinitionId, resourceGroup().id)

param websiteName string = 'toyrnd1-${uniqueString(resourceGroup().id)}'

param storageAccountName string = 'storage${uniqueString(resourceGroup().id)}'
var blobContainerNames = [
  'productspecs'
  'productmanuals'
]

@allowed([
  'Production'
  'Test'
])
param environmentType string

@description('Define the SKUs for each component based on the environment type.')
var environmentConfigurationMap = {
  Production: {
    appServicePlan: {
      sku: {
        name: 'S1'
        capacity: 2
      }
    }
    storageAccount: {
      sku: {
        name: 'Standard_GRS'
      }
    }
    sqlDatabase: {
      sku: {
        name: 'S1'
        tier: 'Standard'
      }
    }
  }
  Test: {
    appServicePlan: {
      sku: {
        name: 'F1'
        capacity: 1
      }
    }
    storageAccount: {
      sku: {
        name: 'Standard_lRS'
      }
    }
    sqlDatabase: {
      sku: {
        tier: 'Basic'
      }
    }
  }
}

var hostingPlanName = 'hostingPlan-${uniqueString(resourceGroup().id)}'
var sqlServerName = 'sqlserver-${uniqueString(resourceGroup().id)}'
var sqlDatabaseName = 'sqldatabase-${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: environmentConfigurationMap[environmentType].storageAccount.sku
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }

  resource blobServices 'blobServices' existing = {
    name: 'default'

    resource blobContainers 'containers' = [for blobContainerName in blobContainerNames: {
      name: blobContainerName
    }]
  }
}

resource sqlServer 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorPassword
    version: '12.0'
  }

  resource sqlServerNameAllowAllAzureIPs 'firewallRules' = {
    name: 'AllowAllAzureIPs'
    properties: {
      startIpAddress: '0.0.0.0'
      endIpAddress: '0.0.0.0'
    }
  }

  resource sqlDatabase 'databases' = {
    name: sqlDatabaseName
    location: location
    sku: environmentConfigurationMap[environmentType].sqlDatabase.sku
    properties: {
      collation: 'SQL_Latin1_General_CP1_CI_AS'
      maxSizeBytes: 2147483648
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${websiteName}-appInsights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource msi 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}

resource hostingPlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: hostingPlanName
  location: location
  sku: environmentConfigurationMap[environmentType].appServicePlan.sku
}

resource webSite 'Microsoft.Web/sites@2021-02-01' = {
  name: websiteName
  location: location
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'StorageAccountConnectionString'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
      ]
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${msi.id}': {} 
    }
  }  
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(contributorRoleDefinitionId, resourceGroup().id)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleDefinitionId)
    principalId: msi.properties.principalId
    principalType: 'ServicePrincipal'
  }
}
