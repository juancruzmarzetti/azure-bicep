param location string = resourceGroup().location
param vmName string = 'myVirtualMachine'
param nicName string = 'myNetworkInterface'
param OsDiskName string = 'myOsDisk'
param vmSize string = 'Standard_A2_v2'

param adminUsername string

@minLength(12)
@secure()
param adminPassword string

// In a real life bicep modularized code, the subnetResourceId would more
// likely come from the output of the virtual network module, as well as the networkInterface resource.
// This non realistic example is just to show how we can chain modules together 
// by using the output of one module as the value of a parameter of another module.
param subnetResourceId string

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetResourceId
          }
        }
      }
    ]
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        name: OsDiskName
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
  }
}
