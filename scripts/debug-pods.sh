#!/bin/bash

echo "=== Pod Debugging Script ==="
echo ""

# Get all pods in moviebox namespace
PODS=$(kubectl get pods -n moviebox -o name 2>/dev/null)

if [ -z "$PODS" ]; then
    echo "No pods found in moviebox namespace"
    exit 1
fi

for pod in $PODS; do
    POD_NAME=$(echo $pod | cut -d'/' -f2)
    echo "=== Debugging $POD_NAME ==="
    
    # Get pod status
    echo "Pod Status:"
    kubectl get pod $POD_NAME -n moviebox
    echo ""
    
    # Get pod description
    echo "Pod Events:"
    kubectl describe pod $POD_NAME -n moviebox | grep -A 10 "Events:"
    echo ""
    
    # Get pod logs
    echo "Pod Logs (last 20 lines):"
    kubectl logs $POD_NAME -n moviebox --tail=20 2>/dev/null || echo "No logs available"
    echo ""
    echo "----------------------------------------"
    echo ""
done

# Check MongoDB connectivity
echo "=== MongoDB Connectivity Test ==="
MONGO_POD=$(kubectl get pods -n moviebox -l app=mongo -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ ! -z "$MONGO_POD" ]; then
    echo "Testing MongoDB connection..."
    kubectl exec $MONGO_POD -n moviebox -- mongosh --eval "db.adminCommand('ping')" 2>/dev/null || echo "MongoDB connection failed"
else
    echo "MongoDB pod not found"
fi

echo ""
echo "=== Service Endpoints ==="
kubectl get endpoints -n moviebox
