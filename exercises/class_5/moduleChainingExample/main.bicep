param location string = resourceGroup().location

@secure()
param adminUsername string

@secure()
@minLength(12)
param adminPassword string

module virtualNetwork 'modules/virtualNetwork.bicep' = {
  name: 'virtualNetwork'
  params: {
    location: location
  }
}

module virtualMachine 'modules/virtualMachine.bicep' = {
  name: 'virtualMachine'
  params: {
    location: location
    subnetResourceId: virtualNetwork.outputs.subnetResourceId
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}
