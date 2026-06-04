#!/bin/bash

# This script is used to deploy the final Bicep template (main.bicep) to the test environment 
# using the Azure CLI and test parameters.
RESOURCE_GROUP="myResourceGroupName"
TEMPLATE_FILE="./main.bicep"
PARAMETERS_FILE="./parameters.test.json"

echo "Deploying to test environment..."
az deployment group create \
  -g $RESOURCE_GROUP \
  -f $TEMPLATE_FILE \
  --parameters @$PARAMETERS_FILE \
  -c
