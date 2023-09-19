#!/bin/bash

# Create a Kubernetes cluster with kind
kind create cluster --config ./cluster_config.yaml --name ignite-cluster

# Download kubeconfig
mkdir -p ~/.kube
kind get kubeconfig --name ignite-cluster > ~/.kube/config
