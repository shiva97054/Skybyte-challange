#!/usr/bin/env bash
set -Eeuo pipefail

echo "🔧 Starting setup..."

# ---------------------------
# 0) Pre-checks
# ---------------------------
command -v docker >/dev/null 2>&1 || { echo "❌ Docker not installed"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl not installed"; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "❌ Helm not installed"; exit 1; }
command -v terraform >/dev/null 2>&1 || { echo "❌ Terraform not installed"; exit 1; }
command -v minikube >/dev/null 2>&1 || { echo "❌ Minikube not installed"; exit 1; }

# ---------------------------
# 1) Start / ensure cluster
# ---------------------------
echo "🚀 Ensuring Kubernetes cluster is running..."
if ! kubectl cluster-info >/dev/null 2>&1; then
  echo "⚠️ Cluster not running → starting Minikube"
  minikube start --driver=docker
else
  echo "✅ Cluster already running"
fi

kubectl get nodes

# ---------------------------
# 2) Build Docker image
# ---------------------------
echo "🐳 Building Docker image..."
docker build -t skybyte-app:latest .

# Load image into Minikube (important)
echo "📦 Loading image into Minikube..."
minikube image load skybyte-app:latest

# ---------------------------
# 3) Terraform apply
# ---------------------------
echo "🌍 Applying Terraform..."
pushd terraform >/dev/null
terraform init -input=false
terraform apply -auto-approve -input=false
popd >/dev/null

# ---------------------------
# 4) Create/ensure secret (idempotent)
# ---------------------------
echo "🔐 Ensuring Kubernetes Secret exists..."
kubectl create secret generic app-secret \
  --from-literal=password=mysecret123 \
  --dry-run=client -o yaml | kubectl apply -f -

# ---------------------------
# 5) Deploy with Helm (idempotent)
# ---------------------------
echo "📦 Deploying Helm chart..."
helm upgrade --install skybyte ./helm/skybyte-app

# ---------------------------
# 6) Wait for rollout
# ---------------------------
echo "⏳ Waiting for deployment rollout..."
kubectl rollout status deployment/skybyte-skybyte-app --timeout=120s
  echo "❌ Rollout failed"
  kubectl describe deployment skybyte-app || true
  kubectl get pods -o wide || true
  exit 1
}

# ---------------------------
# 7) Show status
# ---------------------------
echo "📊 Current resources:"
kubectl get pods
kubectl get svc

echo "🎉 Setup completed successfully!"
