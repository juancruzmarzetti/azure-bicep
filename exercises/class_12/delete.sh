#!/bin/bash

# This is for example purpose only, in general if we deploy something we don't want to delete it immediately after.
# Or only we want to delete it immediately after if we are just testing.
# (we can also automate the deploy and delete stages using azure pipelines,
# for example, making manual the delete stage on the azure pipeline so we can decide when to delete it)
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
SUBSCRIPTION_SCOPE="/subscriptions/${SUBSCRIPTION_ID}"

AZ_POLICY_ASSIGNMENT_NAME="DenyFandGSeriesVMs"
AZ_POLICY_DEFINITION_NAME="DenyFandGSeriesVMs"
AZ_RESOURCE_GROUP_NAME="ToyNetworking"

echo "Deleting policy assignment..."
az policy assignment delete \
  --name $AZ_POLICY_ASSIGNMENT_NAME \
  --scope $SUBSCRIPTION_SCOPE

echo "Deleting policy definition..."
az policy definition delete \
  --name $AZ_POLICY_DEFINITION_NAME \
  --scope $SUBSCRIPTION_SCOPE

echo "Deleting resource group..."
az group delete \
  --name $AZ_RESOURCE_GROUP_NAME \