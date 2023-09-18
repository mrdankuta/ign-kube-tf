#!/bin/bash

# Create a Kubernetes cluster with kind
kind create cluster --name ignite-cluster

# Download kubeconfig
mkdir -p ~/.kube
kind get kubeconfig --name ignite-cluster > ~/.kube/config
