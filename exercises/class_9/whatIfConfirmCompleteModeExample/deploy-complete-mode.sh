#!/bin/bash

RESOURCE_GROUP="myResourceGroupName"
# LOCATION="eastus" --> Not necessary if the resource group already exists
TEMPLATE_FILE="./main.bicep"

# echo "Logging on Azure..."
# az login

# echo "Creating resource group: $RESOURCE_GROUP..."
# az group create --name $RESOURCE_GROUP --location $LOCATION

echo "Deploying..."
az deployment group create \
  -g $RESOURCE_GROUP \
  -f $TEMPLATE_FILE \
  --mode Complete \
  -c 

echo "¡Despliegue finalizado con éxito!"
