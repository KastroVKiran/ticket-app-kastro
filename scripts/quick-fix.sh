#!/bin/bash

echo "=== Quick Fix for MovieBox Deployment ==="

# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name kastro-eks

# Delete all problematic pods and deployments
echo "1. Cleaning up problematic deployments..."
kubectl delete deployment user-service payment-service booking-service movie-service mongo -n moviebox --ignore-not-found=true
kubectl delete pvc mongo-pvc -n moviebox --ignore-not-found=true

# Wait for cleanup
echo "2. Waiting for cleanup..."
sleep 20

# Deploy MongoDB first (without PVC)
echo "3. Deploying MongoDB..."
kubectl apply -f k8s/mongodb-deployment.yaml

# Wait for MongoDB
echo "4. Waiting for MongoDB..."
kubectl wait --for=condition=available deployment/mongo -n moviebox --timeout=120s

# Deploy all services
echo "5. Deploying all microservices..."
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

# Deploy ingress
echo "6. Deploying ingress..."
kubectl apply -f k8s/ingress.yaml

# Wait for deployments
echo "7. Waiting for all deployments..."
sleep 30

# Check status
echo "8. Checking final status..."
kubectl get pods -n moviebox
kubectl get svc -n moviebox

echo ""
echo "=== Fix Complete ==="
echo "If all pods are running, your application should be accessible via the LoadBalancer URL"
