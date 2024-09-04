#!/bin/bash

# Variables
resourceGroup="acdnd-c4-project"
clusterName="udacity-cluster"
region="westeurope"
myAcrName="project4acr"

# Install aks cli
echo "Installing AKS CLI"

az aks install-cli

echo "AKS CLI installed"

# Create AKS cluster
echo "Step 1 - Creating AKS cluster $clusterName"
# Use either one of the "az aks create" commands below
# For users working in their personal Azure account
# This commmand will not work for the Cloud Lab users, because you are not allowed to create Log Analytics workspace for monitoring
az aks create \
    --resource-group $resourceGroup \
    --name $clusterName \
    --node-count 1 \
    --enable-addons monitoring \
    --generate-ssh-keys \
    --location $region \
    --attach-acr $myAcrName

# For Cloud Lab users
 az aks create \
     --resource-group $resourceGroup \
     --name $clusterName \
     --node-count 1 \
     --generate-ssh-keys \
     --location eastus


# For Cloud Lab users
# This command will is a substitute for "--enable-addons monitoring" option in the "az aks create"
# Use the log analytics workspace - Resource ID
# For Cloud Lab users, go to the existing Log Analytics workspace --> Properties --> Resource ID. Copy it and use in the command below.
az aks enable-addons -a monitoring -n $clusterName -g $resourceGroup --workspace-resource-id "/subscriptions/62d70a26-cec0-4efb-878f-bb4ba7135ee6/resourcegroups/cloud-demo/providers/microsoft.operationalinsights/workspaces/loganalytics-267214"
echo "AKS cluster created: $clusterName"

# Connect to AKS cluster

echo "Step 2 - Getting AKS credentials"

az aks get-credentials \
    --resource-group $resourceGroup \
    --name $clusterName \
    --verbose

echo "Verifying connection to $clusterName"

kubectl get nodes

echo "Deploying to AKS cluster"


az aks update -n $clusterName -g $resourceGroup --attach-acr $myAcrName

kubectl apply -f ../azure-vote-all-in-one-redis.yaml

az acr show --name $myAcrName --query loginServer --output table
kubectl set image deployment azure-vote-front azure-vote-front=$myAcrName.azurecr.io/azure-vote-front:v1
kubectl get service
kubectl get pods
kubectl autoscale deployment azure-vote-front --cpu-percent=50 --min=1 --max=10
