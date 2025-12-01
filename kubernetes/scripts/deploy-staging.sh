#!/bin/bash
# Deploy CloudNorth to staging environment

set -e

echo "========================================="
echo "CloudNorth Staging Deployment"
echo "========================================="

# Check for kubectl
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl not found. Please install kubectl."
    exit 1
fi

# Deploy using kustomize
echo "Applying staging configuration..."
kubectl apply -k overlays/staging/

echo ""
echo "Waiting for deployments to be ready..."
kubectl rollout status deployment/backend -n cloudnorth --timeout=180s
kubectl rollout status deployment/frontend -n cloudnorth --timeout=180s

echo ""
echo "Deployment Status:"
echo "=================="
kubectl get all -n cloudnorth

# Get LoadBalancer IP
echo ""
echo "Application Access:"
LOADBALANCER_IP=$(kubectl get service frontend -n cloudnorth -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
if [ -n "$LOADBALANCER_IP" ]; then
    echo "Frontend: http://$LOADBALANCER_IP"
    echo "Backend API: http://$LOADBALANCER_IP/api"
    echo "Health Check: http://$LOADBALANCER_IP/api/health"
else
    echo "No LoadBalancer IP found. You can use port-forward:"
    echo "  kubectl port-forward service/frontend -n cloudnorth 8080:80"
    echo "Then access: http://localhost:8080"
fi

echo ""
echo "========================================="
echo "Deployment Complete!"
echo "========================================="
