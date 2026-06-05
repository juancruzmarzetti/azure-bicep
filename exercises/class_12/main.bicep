targetScope = 'subscription'

param virtualNetworkName string
param virtualNetworkAddressPrefix string

var policyDefinitionName = 'DenyFandGSeriesVMs'
var policyAssignmentName = 'DenyFandGSeriesVMs'
var resourceGroupName = 'ToyNetworking'

/*
  An azure policy definition specifies the rules that a certain group of resources should follow.
  One the things you can do is put a little gate when somebody is trying to deploy
  a resource, regardless of where that deployment comes from 
  (portal, cli, powershell, arm template, bicep template, etc.),
  and the actual deployment being executed.
  If the resource being deployed doesn't follow the rules specified in the policy definition, 
  then the deployment will be blocked.
  This is the more common use of azure policy, but you can use it for other things as well.
*/

// In this case we create a policyDefinition resource to block the deployment of certain types of virtual machines, 
// specifically the F and G series, which are very expensive and aren't likely needed for our workloads.
// if any of all of our virtual machines have a sku name that starts with Standard_F or Standard_G, 
// then we want to block their deployment.
resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyDefinitionName
  properties: {
    description: 'This policy blocks the deployment of F and G series virtual machines.'
    policyType: 'Custom'
    mode: 'All'
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Compute/virtualMachines'
          }
          {
            anyOf: [
              {
                field: 'Microsoft.Compute/virtualMachines/sku.name'
                like: 'Standard_F*'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/sku.name'
                like: 'Standard_G*'
              }
            ]
          }
        ]
      }
      then: {
        effect: 'deny'
      }
    }
  }
}

// Create a policy assignment to apply the policy definition
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2026-01-01-preview' = {
  name: policyAssignmentName
  properties: {
    description: 'This policy assignment blocks the deployment of F and G series virtual machines.'
    policyDefinitionId: policyDefinition.id
  }
}

//Also we create a resource group, within our subscription.
resource resourceGroupForVnet 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: deployment().location
}

//And we create a virtual network within that resource group.
module vnet 'modules/vnet.bicep' = {
  name: 'virtualNetworkModule'
  scope: resourceGroupForVnet
  params: {
    virtualNetworkName: virtualNetworkName
    virtualNetworkAddressPrefix: virtualNetworkAddressPrefix
  }
}
