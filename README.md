# Implementation of the Ignite.Dev Internship Task

## Setup a kubernetes cluster using kind

1. Write a simple bash script that deploys a [kind](https://kind.sigs.k8s.io/docs/user/quick-start/) cluster locally
2. Download the kubeconfig for the cluster and store in a safe place, we will use it much later in the next steps

## Deploy a sample Node.js app using terraform

1. When kind is up and running, dockerize a simple hello world [express](https://expressjs.com/en/starter/hello-world.html) and deploy to dockerhub
2. create a kubernetes deployment manifest to deploy to deploy the Node.js to the kind cluste but don't apply it yet
3. using the [kubectl terraform provider](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs), write a terraform code to deploy the kubectl manifest to the kind cluster

## Bonus

1. Using the [kube-prometheus stack](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/README.md), using [terraform helm provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs), setup monitoring and observability for the prometheus cluster.


--- 

# My Implementation Documentation

### To follow along, please note:

1. **Linux Environment**: You need a Linux/Unix environment to run the commands mentioned in this guide. You can use WSL or a virtual machine if you're on Windows.

2. **Docker**: Make sure Docker is installed on your machine as it is required to run Kubernetes in Docker (kind).

3. **kubectl**: Install `kubectl`, the Kubernetes command-line tool, to interact with your Kubernetes cluster. See the [Docs](https://kubernetes.io/docs/tasks/tools/) for installation guide.

4. **Terraform**: Install Terraform for infrastructure provisioning. I use [tfenv](https://github.com/tfutils/tfenv) to install and manage Terraform versions.

5. **Node.js**: Install Node.js if you haven't already. See the [Docs](https://nodejs.org/) for installation guide.

6. **DockerHub Account**: Create a [DockerHub](https://hub.docker.com) account if you don't have one to push your Docker images.

## Step 1: Setup a Kubernetes Cluster using kind
- Install `kind`
    ```bash
    # Install kind (Kubernetes in Docker)
    [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
    ```

## Step 2: Write a Bash Script for Cluster Deployment

- Create a Bash script to automate the cluster deployment process. Let's call it `ignite_cluster.sh`:

    ```bash
    #!/bin/bash

    # Create a Kubernetes cluster with kind
    kind create cluster --name ignite-cluster

    # Download kubeconfig
    mkdir -p ~/.kube
    kind get kubeconfig --name ignite-cluster > ~/.kube/config
    ```

- Make the script executable:

    ```bash
    chmod +x ignite_cluster.sh
    ```

- Run the script:

    ```bash
    ./ignite_cluster.sh
    ```


## Step 3: Dockerize a Simple Express App and Push to DockerHub

- Create a simple `Hello Word` Node.js/Express app with the following steps
  - Create a directory named `ignapp` and `cd` into it
  - Run `npm init`
  - Install `express` by running `npm install express`
  - Create a file named `ignapp.js` and insert the following code:
  ```
    const express = require('express')
    const app = express()
    const port = 3210

    app.get('/', (req, res) => {
    res.send('Hello World!')
    })

    app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
    })
  ```
  - Run `node ignapp.js` and use postman to send a GET request to `localhost:3210` to get `Hello World` as a response.

- Now, Dockerize it! Create a `Dockerfile` in the `ignapp` directory and insert the following code:

    ```Dockerfile
    # Use an official Node.js runtime as the base image
    FROM node:20-alpine

    # Set the working directory in the container
    WORKDIR /app

    # Copy package.json and package-lock.json to the working directory
    COPY package*.json ./

    # Install app dependencies
    RUN npm install

    # Copy the rest of the application code to the working directory
    COPY . .

    # Expose port 3210
    EXPOSE 3210

    # Define the command to run the application
    CMD ["node", "ignapp.js"]
    ```

- Build and push the Docker image:

    ```bash
    docker build -t <your-dockerhub-username>/ignapp:1.0 .
    docker push <your-dockerhub-username>/ignapp:1.0
    ```

**Step 4: Create a Kubernetes Deployment Manifest**

- Create a directory called `ign_deployment` to hold our deployment code.
- Within the `ign_deployment`, create a Kubernetes deployment manifest file called `ign_k8s_deployment.yaml` for our app. Insert the following code which will pull our image from docker hub and deploy into the cluster:

    ```yaml
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
    name: ignapp
    spec:
    replicas: 3
    selector:
        matchLabels:
        app: ignapp
    template:
        metadata:
        labels:
            app: ignapp
        spec:
        containers:
            - name: ignapp
            image: dankuta/ignapp:1.0
            ports:
                - containerPort: 3210
    ```

## Step 5: Deploy the Node.js App to the Kubernetes Cluster using the Deployment Manifest and Terraform

- Create a Terraform configuration to deploy the Kubernetes manifest created above using the `kubectl` Terraform provider. Add the following to your `main.tf`. Your Terraform configuration can be structured thus within the `ign_deployment` directory:
    ```
    ign_deployment/
    ├── main.tf
    └── variables.tf
    ```
    > Remember to add the variable for the kubernetes config path. This is how Terraform would know what cluster to deploy into.

    ```hcl
    terraform {
    required_version = ">= 0.13"

    required_providers {
        kubectl = {
        source  = "gavinbunney/kubectl"
        version = ">= 1.7.0"
        }
    }
    }

    provider "kubectl" {
    load_config_file = true
    config_path      = var.kube_config_path
    }

    resource "kubectl_manifest" "ignapp" {
    yaml_body = file("${path.module}/ign_k8s_deployment.yaml")
    }
    ```
- Run `terraform init`, `terraform plan`, and `terraform apply` to deploy the app into `ignite_cluster`