#!/bin/bash

# Script to check and install NGINX Ingress Controller if not present
echo "Checking NGINX Ingress Controller status..."

# Check if ingress-nginx namespace exists
if kubectl get namespace ingress-nginx >/dev/null 2>&1; then
    echo "✅ NGINX Ingress Controller namespace exists"
    
    # Check if controller is running
    if kubectl get pods -n ingress-nginx -l app.kubernetes.io/component=controller | grep -q Running; then
        echo "✅ NGINX Ingress Controller is running"
        kubectl get svc ingress-nginx-controller -n ingress-nginx
    else
        echo "⚠️  NGINX Ingress Controller pods are not running"
        kubectl get pods -n ingress-nginx
    fi
else
    echo "❌ NGINX Ingress Controller not found. Installing..."
    
    # Install NGINX Ingress Controller
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/aws/deploy.yaml
    
    # Wait for installation to complete
    echo "Waiting for NGINX Ingress Controller to be ready..."
    kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=300s
    
    echo "✅ NGINX Ingress Controller installed successfully"
    kubectl get svc ingress-nginx-controller -n ingress-nginx
fi

echo ""
echo "=== LoadBalancer Information ==="
LB_URL=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
if [ ! -z "$LB_URL" ]; then
    echo "LoadBalancer URL: $LB_URL"
    echo "Add this to your /etc/hosts file:"
    echo "$LB_URL moviebox.local"
else
    echo "LoadBalancer URL not yet available. Please wait a few minutes and run:"
    echo "kubectl get svc ingress-nginx-controller -n ingress-nginx"
fi
