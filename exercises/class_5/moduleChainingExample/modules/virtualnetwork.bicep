param location string = resourceGroup().location

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: 'virtualNetwork'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: 'subnet01'
  parent: virtualNetwork
  properties: {
    addressPrefix: '10.0.1.0/24'
  }
}

output subnetResourceId string = subnet.id
