#!/bin/bash
start_minikube(){
# Start Minikube
echo "Starting Minikube..."
minikube start

# Enable Ingress addon
echo "Enabling Ingress addon..."
minikube addons enable ingress
}

build_images(){
# Set Docker environment to use Minikube's Docker daemon
echo "Setting Docker environment to use Minikube's Docker daemon..."
eval $(minikube docker-env)

# Build Docker images
echo "Building Docker images..."
docker build -t backend-image:latest ./backend
docker build -t frontend-image:latest ./frontend
}
#WARNING: DONT DO THIS IN A REAL WORLD SCENARIO
#this are hard coded values for the secrets
#this is just for testing purposes, in a real world scenario DONT DO THIS!!!
add_secret(){
    echo "Creating DB Secret secret"
    kubectl create secret generic postgres-secret   --from-literal=POSTGRES_USER=admin   --from-literal=POSTGRES_PASSWORD=securepassword   --from-literal=POSTGRES_DB=userdb
    echo "Creating TLS secret"
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout myapp-tls.key -out myapp-tls.crt -subj "/CN=myapp.local/O=myapp.local"
    kubectl create secret tls myapp-tls --cert=myapp-tls.crt --key=myapp-tls.key
}
apply_k8(){
    # Apply Kubernetes configurations
    echo "Applying Kubernetes configurations..."
    kubectl apply -f ./k8/postgres-init-configmap.yaml
    kubectl apply -f ./k8/postgres-deployment-service.yaml
    kubectl apply -f ./k8/backend-deployment-service.yaml
    kubectl apply -f ./k8/frontend-deployment-service.yaml
    kubectl apply -f ./k8/tls-ingress.yaml
    #Wait for all pods to be ready
    echo "Waiting for all pods to be ready..."
    kubectl wait --for=condition=ready pod --all --timeout=300s
    echo "All pods are ready!"
}

open_frontend(){
# Get Minikube IP
MINIKUBE_IP=$(minikube ip)
echo "Minikube IP: $MINIKUBE_IP"



# Open the frontend in the default web browser
# Display message to update /etc/hosts file manually
echo "Please add the following entry to your local DNS resolver:"
echo "For Linux and macOS, add the following entry to your /etc/hosts file:"
echo "$MINIKUBE_IP myapp.local"
echo "For Windows, add the following entry to your C:\\Windows\\System32\\drivers\\etc\\hosts file:"
echo "$MINIKUBE_IP myapp.local"

echo "$MINIKUBE_IP myapp.local"
echo "Opening the frontend in the default web browser..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    xdg-open https://myapp.local
elif [[ "$OSTYPE" == "darwin"* ]]; then
    open https://myapp.local
elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    start https://myapp.local
else
    echo "Unsupported OS: Please open https://myapp.local manually."
fi
echo "You can access the frontend at https://myapp.local"
echo "You have to accept the self-signed certificate to proceed."
}

delete_all(){
    minikube stop && minikube delete
    if [ -f myapp-tls.crt ] && [ -f myapp-tls.key ]; then
        rm myapp-tls.crt myapp-tls.key
    fi
}

rebuild_and_redeploy(){
    build_images
    apply_k8   
}
start(){
    start_minikube
    build_images
    add_secret
    apply_k8
    open_frontend
}
case $1 in
    apply)
        apply_k8
        ;;
    clean-start)
        delete_all
        start
        ;;
    start)
        start
        ;;
    clean)
        delete_all
        ;;
    rebuild)
        rebuild_and_redeploy
        ;;
    open)
        open_frontend
        ;;
    *)
        echo "Usage: $0 {start|clean|apply|clean-start|rebuild|open}"
        echo ""
        echo "start: Starts Minikube, builds Docker images, adds secrets, applies Kubernetes configurations, and opens the frontend."
        echo "clean: Stops and deletes Minikube and removes TLS certificates."
        echo "apply: Applies Kubernetes configurations."
        echo "clean-start: Deletes all resources, then starts Minikube, builds Docker images, adds secrets, applies Kubernetes configurations, and opens the frontend."
        echo "rebuild: Rebuilds Docker images and redeploys Kubernetes configurations."
        echo "open: Opens the frontend of the application in the default web browser."
        
        exit 1
        ;;
esac