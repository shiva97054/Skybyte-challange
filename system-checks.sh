#!/usr/bin/env bash
set -Eeuo pipefail

echo "🔍 Running system checks..."

# ---------------------------
# 1) Get pod name dynamically
# ---------------------------
POD=$(kubectl get pods -o jsonpath='{.items[0].metadata.name}')
echo "📦 Pod: $POD"

# ---------------------------
# 2) Check container user (non-root)
# ---------------------------
echo "👤 Checking container user..."
kubectl exec "$POD" -- id

# ---------------------------
# 3) Check open ports
# ---------------------------
echo "🌐 Checking listening ports..."
kubectl exec "$POD" -- netstat -tuln || echo "⚠ netstat not available"

# ---------------------------
# 4) Port-forward service
# ---------------------------
echo "🔌 Port forwarding..."
kubectl port-forward "$POD" 8080:8080 >/dev/null 2>&1 &
PF_PID=$!
sleep 5

# ---------------------------
# 5) Test main endpoint
# ---------------------------
echo "🌍 Testing / endpoint..."
curl -s localhost:8080 | grep "Hello" && echo "✅ App response OK"

# ---------------------------
# 6) Test metrics endpoint
# ---------------------------
echo "📊 Testing /metrics..."
curl -s localhost:8080/metrics | grep http_requests_total && echo "✅ Metrics working"

# ---------------------------
# 7) Kill pod to test recovery
# ---------------------------
echo "💣 Deleting pod to test recovery..."
kubectl delete pod "$POD"

echo "⏳ Waiting for new pod..."
sleep 10

kubectl get pods

# ---------------------------
# 8) Cleanup port-forward
# ---------------------------
kill $PF_PID || true

echo "🎉 All system checks completed!"
