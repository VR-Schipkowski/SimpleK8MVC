#!/bin/bash

# Start Minikube
echo "Starting Minikube..."
minikube start

# Enable Ingress addon
echo "Enabling Ingress addon..."
minikube addons enable ingress

# Set Docker environment to use Minikube's Docker daemon
echo "Setting Docker environment to use Minikube's Docker daemon..."
eval $(minikube docker-env)

# Build Docker images
echo "Building Docker images..."
docker build -t backend-image:latest ./backend
docker build -t frontend-image:latest ./frontend

# Apply Kubernetes configurations
echo "Applying Kubernetes configurations..."
kubectl create secret generic postgres-secret   --from-literal=POSTGRES_USER=admin   --from-literal=POSTGRES_PASSWORD=securepassword   --from-literal=POSTGRES_DB=userdb
kubectl apply -f ./k8/postgres-init-configmap.yaml
kubectl apply -f ./k8/postgres-deployment-service.yaml
kubectl apply -f ./k8/backend-deployment-service.yaml
kubectl apply -f ./k8/frontend-deployment-service.yaml
kubectl apply -f ./k8/ingress.yaml

# Get Minikube IP
MINIKUBE_IP=$(minikube ip)
echo "Minikube IP: $MINIKUBE_IP"

#Wait for all pods to be ready
echo "Waiting for all pods to be ready..."
kubectl wait --for=condition=ready pod --all --timeout=300s

# Update /etc/hosts file
echo "add to /etc/hosts file..."
echo "$MINIKUBE_IP myapp.local"
# Open the frontend in the default web browser


echo "Opening the frontend in the default web browser..."
xdg-open http://myapp.local

echo "Setup complete!"
echo "You can access the frontend at http://myapp.local"
echo "To stop Minikube, run 'minikube stop'"
echo "To delete Minikube, run 'minikube delete'"