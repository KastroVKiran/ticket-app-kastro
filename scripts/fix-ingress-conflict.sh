#!/bin/bash

echo "=== Fixing Ingress Conflict ==="
echo ""

# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name kastro-eks

echo "1. Checking existing ingress resources..."
kubectl get ingress -A

echo ""
echo "2. Deleting conflicting ingress from default namespace..."
kubectl delete ingress microservices-ingress --ignore-not-found=true

echo ""
echo "3. Deleting existing moviebox ingress..."
kubectl delete ingress moviebox-ingress -n moviebox --ignore-not-found=true

echo ""
echo "4. Waiting for cleanup..."
sleep 10

echo ""
echo "5. Applying new ingress configuration..."
kubectl apply -f k8s/ingress.yaml

echo ""
echo "6. Checking ingress status..."
kubectl get ingress -n moviebox

echo ""
echo "7. Getting LoadBalancer URL..."
LB_URL=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)

if [ ! -z "$LB_URL" ]; then
    echo "✅ LoadBalancer URL: $LB_URL"
    echo ""
    echo "🌐 Your application should be accessible at:"
    echo "   http://$LB_URL"
    echo ""
    echo "📋 Service URLs:"
    echo "   User Service:     http://$LB_URL/user-service"
    echo "   Movie Service:    http://$LB_URL/movie-service"
    echo "   Theater Service:  http://$LB_URL/theater-service"
    echo "   Booking Service:  http://$LB_URL/booking-service"
    echo "   Payment Service:  http://$LB_URL/payment-service"
    echo "   Admin Dashboard:  http://$LB_URL/user-service/admin"
else
    echo "⚠️  LoadBalancer URL not yet available"
fi

echo ""
echo "=== Fix Complete ==="
