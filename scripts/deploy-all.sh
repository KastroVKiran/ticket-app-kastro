#!/bin/bash

# Deploy all services to Kubernetes
echo "Deploying MovieBox to Kubernetes..."

# Create namespace
kubectl apply -f k8s/namespace.yaml

# Deploy MongoDB
kubectl apply -f k8s/mongodb-deployment.yaml

# Wait for MongoDB to be ready
echo "Waiting for MongoDB to be ready..."
kubectl wait --for=condition=ready pod -l app=mongo -n moviebox --timeout=300s

# Deploy all services
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
kubectl apply -f k8s/ingress.yaml

# Wait for all deployments to be ready
echo "Waiting for all services to be ready..."
kubectl wait --for=condition=ready pod -l app=user-service -n moviebox --timeout=300s
kubectl wait --for=condition=ready pod -l app=movie-service -n moviebox --timeout=300s
kubectl wait --for=condition=ready pod -l app=theater-service -n moviebox --timeout=300s
kubectl wait --for=condition=ready pod -l app=booking-service -n moviebox --timeout=300s
kubectl wait --for=condition=ready pod -l app=payment-service -n moviebox --timeout=300s

echo "All services deployed successfully!"
kubectl get pods -n moviebox
kubectl get services -n moviebox
kubectl get ingress -n moviebox