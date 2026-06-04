#!/bin/bash

# This script is used to decompile the ARM template (template.json) into a Bicep file (template.bicep)
# When we download from the Azure Resource Manager the ARM template of the whole resource group deployment 
# (or a deployment of a specific resource),
# we will have a .zip file in which are the template.json and the parameters.json (which are the production parameters).
# We decompress it and obtain a template.json file and a parameters.json file. 
# To convert it to Bicep, we can use the decompile command using the Azure CLI.
TEMPLATE_FILE="./template.json"

az bicep decompile --file $TEMPLATE_FILE
# This command will generate a template.bicep file in the same directory we are in.