param location string = resourceGroup().location

module storageContainer 'modules/storagecontainer.bicep' = {
  name: 'storageContainer'
  params: {
    location: location
  }
}

var containerId = storageContainer.outputs.blobContainerResourceId
// We can chain modules by using the output of one module as a value of a param of another module.
// Example of this in the moduleChainingExample folder.
