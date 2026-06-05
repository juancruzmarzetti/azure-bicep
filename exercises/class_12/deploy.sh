#!/bin/bash

TEMPLATE_FILE="./main.bicep"
TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
DEPLOYMENT_NAME="deploy-sub-scope-${TIMESTAMP}"
LOCATION="westus"
PARAMETERS_FILE="./parameters.bicepparam"

echo "Deploying (manangement group scope)..."
az deployment sub create \
  --name $DEPLOYMENT_NAME \
  --location $LOCATION \
  -f $TEMPLATE_FILE \
  --parameters $PARAMETERS_FILE \
  -c