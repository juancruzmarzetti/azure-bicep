@description('List of files to copy to application storage account.')
param filesToCopy array


@description('The location to deploy our resources. The default location is the location of the resource group.')
param location string = resourceGroup().location

var storageAccountName = 'storage-${uniqueString(resourceGroup().id)}'
var storageBlobContainerName = 'config'
var userAssignedIdentityName = 'configDeployer'
var deploymentScriptName = 'ourDeploymentScriptName'

var roleAssignmentName = guid(resourceGroup().id, 'contributor')
/*                        |
                          |
 This function will generate a guid for us.
 It will be consistent across deployments as long as the resource group stays the same
*/
var contributorRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

resource storageAccount 'Microsoft.Storage/storageAccounts@2026-04-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  tags: {
    displayName: storageAccountName
  }
  properties: {
    encryption: {
      services: {
        blob: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    supportsHttpsTrafficOnly: true
  }

  resource blobService 'blobServices' = {
    name: 'default'

    resource blobContainer 'containers' = {
      name: storageBlobContainerName
      properties: {
        publicAccess: 'Blob'
      }
    }
  }
}

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-05-31-preview' = {
  name: userAssignedIdentityName
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleAssignmentName
  properties: {
    principalId: userAssignedIdentity.properties.principalId
    roleDefinitionId: contributorRoleDefinitionId
    principalType: 'ServicePrincipal'
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: deploymentScriptName
  location: location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '16.0.0'
    retentionInterval: 'P1D'
    environmentVariables: [
      {
        name: 'ResourceGroupName'
        value: resourceGroup().name
      }
      {
        name: 'StorageAccountName'
        value: storageAccountName
      }
      {
        name: 'StorageContainerName'
        value: storageBlobContainerName
      }
    ]
    arguments: '-File \'${string(filesToCopy)}\''
    scriptContent: '''
    param([string]$File)
    $fileList = $File -replace '(\[|\])' -split ',' | ForEach-Object { $_.trim() }
    $storageAccount = Get-AzStorageACCOUNT -ResourceGroupName $env:ResoruceGroupName -Name $env:StorageAccountName -Verbose
    $count = 0
    $DeploymentScriptOutputs = @{}
    foreach ($fileName in $fileList) {
      Write-Host "Copying $fileName to $env:StorageContainerName in $env:StorageAccountName"
      Invoke-restMethod 'https://raw.githubhusercontent.com/Azure/azure-docs-json-samples/master/mslearn-arm-deploymentscripts-sample/appsetings.json' -OutFile $fileName
      $storageAccount = Get-AzStorageAccount -ResourceGroupName 'larndeploymentscript_exercise_1' | Where-Object { $_.StorageAccountName -like 'storage' }
      $blob = Set-AzStorageBlonContent -File $fileName -Container $env:StorageContainerName -Blob $fileName -Context $storageAccount.Context
      $DeploymentScriptOutputs[$fileName] = @{}
      $DeploymentScriptOutputs[$fileName]['Uri'] = $blob.ICloudBlob.Uri
      $DeplotmentScriptOutputs[$fileName]['StorageUri'] = $blob.ICloudBlob.StorageUri
      $count++
    }
    Write-Host "Finalized copying $count files."
    '''
  }

  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }

  dependsOn: [
    roleAssignment
    storageAccount::blobService::blobContainer
  ]
}

output fileUri object = deploymentScript.properties.outputs
output storageAccountName string = storageAccountName
