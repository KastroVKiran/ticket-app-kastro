#!/bin/bash

# Install NGINX Ingress Controller
echo "Installing NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/aws/deploy.yaml

# Wait for ingress controller to be ready
echo "Waiting for ingress controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

# Get the LoadBalancer URL
echo "Getting LoadBalancer URL..."
kubectl get svc ingress-nginx-controller -n ingress-nginx

echo "Ingress Controller installation completed!"
echo "Please update your DNS or /etc/hosts file to point moviebox.local to the LoadBalancer external IP"