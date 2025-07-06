#!/bin/bash

echo "=== MovieBox Deployment Fix Script ==="
echo ""

# Update kubeconfig
echo "1. Updating kubeconfig..."
aws eks update-kubeconfig --region us-east-1 --name kastro-eks

# Delete existing problematic deployments
echo "2. Cleaning up existing deployments..."
kubectl delete deployment user-service payment-service -n moviebox --ignore-not-found=true

# Wait for cleanup
echo "3. Waiting for cleanup to complete..."
sleep 10

# Ensure MongoDB is running
echo "4. Checking MongoDB status..."
kubectl get pods -l app=mongo -n moviebox

# If MongoDB is not running, restart it
if ! kubectl get pods -l app=mongo -n moviebox | grep -q Running; then
    echo "MongoDB not running, redeploying..."
    kubectl delete deployment mongo -n moviebox --ignore-not-found=true
    sleep 10
    kubectl apply -f k8s/mongodb-deployment.yaml
    
    echo "Waiting for MongoDB to be ready..."
    kubectl wait --for=condition=ready pod -l app=mongo -n moviebox --timeout=300s
fi

# Redeploy services with proper dependencies
echo "5. Redeploying microservices..."
kubectl apply -f k8s/user-service-deployment.yaml
kubectl apply -f k8s/user-service-service.yaml

kubectl apply -f k8s/movie-service-deployment.yaml
kubectl apply -f k8s/movie-service-service.yaml

kubectl apply -f k8s/theater-service-deployment.yaml
kubectl apply -f k8s/theater-service-service.yaml

kubectl apply -f k8s/booking-service-deployment.yaml
kubectl apply -f k8s/booking-service-service.yaml

kubectl apply -f k8s/payment-service-deployment.yaml
kubectl apply -f k8s/payment-service-service.yaml

# Wait for deployments
echo "6. Waiting for deployments to be ready..."
sleep 30

# Check status
echo "7. Checking deployment status..."
kubectl get pods -n moviebox
kubectl get svc -n moviebox

echo ""
echo "=== Deployment Fix Complete ==="
echo "Check the status above. If pods are still failing, run:"
echo "kubectl logs <pod-name> -n moviebox"
