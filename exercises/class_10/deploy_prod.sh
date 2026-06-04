#!/bin/bash

# This script is used to deploy the final Bicep template (main.bicep) to the production environment 
# using the Azure CLI and production parameters.
RESOURCE_GROUP="myResourceGroupName"
TEMPLATE_FILE="./main.bicep"
PARAMETERS_FILE="./parameters.json"

echo "Deploying to production environment..."
az deployment group create \
  -g $RESOURCE_GROUP \
  -f $TEMPLATE_FILE \
  --parameters @$PARAMETERS_FILE \
  -c