#!/bin/bash

echo "=== MovieBox Application Troubleshooting ==="
echo ""

echo "1. Checking EKS cluster connection..."
kubectl cluster-info

echo ""
echo "2. Checking namespaces..."
kubectl get namespaces

echo ""
echo "3. Checking moviebox namespace resources..."
kubectl get all -n moviebox

echo ""
echo "4. Checking pod status and logs..."
kubectl get pods -n moviebox
echo ""

# Check each service pod logs if they exist
for service in user-service movie-service theater-service booking-service payment-service mongo; do
    echo "--- $service logs ---"
    POD=$(kubectl get pods -n moviebox -l app=$service -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    if [ ! -z "$POD" ]; then
        kubectl logs $POD -n moviebox --tail=20
    else
        echo "No pod found for $service"
    fi
    echo ""
done

echo ""
echo "5. Checking ingress controller..."
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx

echo ""
echo "6. Checking ingress configuration..."
kubectl get ingress -n moviebox
kubectl describe ingress moviebox-ingress -n moviebox

echo ""
echo "7. Checking events..."
kubectl get events -n moviebox --sort-by='.lastTimestamp'

echo ""
echo "8. LoadBalancer URL..."
LB_URL=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
if [ ! -z "$LB_URL" ]; then
    echo "LoadBalancer URL: $LB_URL"
    echo "Application should be accessible at: http://moviebox.local (after DNS/hosts configuration)"
else
    echo "LoadBalancer URL not available yet"
fi