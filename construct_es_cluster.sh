#!/bin/sh

cd $(dirname $0)

set -eux

CLUSTER_NAME=cloud-endpoints-sample-es

## Enable APIs
gcloud services enable deploymentmanager.googleapis.com

## Create GKE Cluster
gcloud --quiet deployment-manager deployments create \
  --automatic-rollback-on-error \
  --template ./deployment-manager/environment.jinja \
  cloud-endpoints-sample

gcloud container clusters get-credentials ${CLUSTER_NAME} --zone asia-northeast1-a

# Create Admin Cluster Role Binding To Current User
kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole=cluster-admin \
  --user=$(gcloud config get-value account 2>/dev/null)
kubectl create -f resource-helm-service-account.yaml

# Initialize helm
helm init --service-account helm --history-max 20
echo "wait for helm init task"
sleep 120

# Install ElasticSearch
helm install -f values.yaml --name ${CLUSTER_NAME} stable/elasticsearch
