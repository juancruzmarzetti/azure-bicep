#!/bin/bash

RESOURCE_GROUP_NAME = "learndeploymentscript_exercise"
TIMESTAMP = $(date +%Y-%m-%d-%H%M%S)
DEPLOYMENT_NAME = "rg-deploy-${TIMESTAMP}"
LOCATION = "eastus"
TEMPLATE_FILE = "main.bicep"
PARAMETERS_FILE = "deploy.parameters.json"


echo "Deploying..."
az deployment group create \
  --name $DEPLOYMENT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --location $LOCATION \
  -f $TEMPLATE_FILE \
  --parameters $PARAMETERS_FILE \
  -c
