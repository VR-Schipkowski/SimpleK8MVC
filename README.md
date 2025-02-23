# SimpleK8MVC

## Introduction
This project demonstrates a simple application deployed on Kubernetes using Minikube. A Backand service proviedes a conection to a database, the frontend-service proviedes a simple view. both connected using tls secured ingress.

## Prerequisites
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)


## Installation

### Install Minikube
Follow the official Minikube installation guide for your operating system: [Minikube Installation](https://minikube.sigs.k8s.io/docs/start/)

### Install kubectl
Follow the official kubectl installation guide: [kubectl Installation](https://kubernetes.io/docs/tasks/tools/install-kubectl/)


## Usage

You can use the provided script: /start.sh
The script was only tested on linux.
Running "/start.sh start" will start the cluster and application, run "./start.sh" for more options. 
For the ingress to work you have to manually add the provided entry to your local DNS resolver.
As the TLS key is created locally, your browser will complain and you have to allow an exception. Have fun.