#!/usr/bin/env bash

set -euo pipefail

REGION="us-east-1"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
REGISTRY="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
CHART_VERSION="8.1.2"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

# Substitute the <ACCOUNT_ID> placeholder in all template files.
for f in namespace.yaml argocd-values.yaml ecr-creds-sync.yaml root-app.yaml; do
  sed "s|<ACCOUNT_ID>|${ACCOUNT_ID}|g" "/tmp/argocd/${f}" > "${WORKDIR}/${f}"
done

# ---------------------------------------------------------------------------
# Step 1: create namespaces
# ---------------------------------------------------------------------------
echo "[1/5] Creating namespaces..."
kubectl apply -f "${WORKDIR}/namespace.yaml"

# ---------------------------------------------------------------------------
# Step 2: log in to ECR for Helm OCI
# ---------------------------------------------------------------------------
echo "[2/5] Logging in to ECR..."
aws ecr get-login-password --region "${REGION}" \
  | helm registry login --username AWS --password-stdin "${REGISTRY}"

# ---------------------------------------------------------------------------
# Step 3: seed the ECR credentials Secret before ArgoCD starts so repo-server
# can pull the platform chart on its very first sync attempt. The CronJob
# (applied later) will keep it fresh every 6 hours.
# ---------------------------------------------------------------------------
echo "[3/5] Seeding argocd-ecr-creds Secret..."
ECR_TOKEN="$(aws ecr get-login-password --region "${REGION}")"

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: argocd-ecr-creds
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  name: ecr-charts
  type: helm
  url: ${REGISTRY}/charts
  enableOCI: "true"
  username: AWS
  password: ${ECR_TOKEN}
---
apiVersion: v1
kind: Secret
metadata:
  name: argocd-ecr-mirror-creds
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  name: ecr-mirror-charts
  type: helm
  url: ${REGISTRY}/charts/mirror
  enableOCI: "true"
  username: AWS
  password: ${ECR_TOKEN}
EOF

# ---------------------------------------------------------------------------
# Step 4: install / upgrade ArgoCD
# ---------------------------------------------------------------------------
echo "[4/5] Installing ArgoCD ${CHART_VERSION}..."
helm upgrade --install argocd \
  "oci://${REGISTRY}/charts/mirror/argo-cd" \
  --version "${CHART_VERSION}" \
  --namespace argocd \
  --values "${WORKDIR}/argocd-values.yaml" \
  --wait \
  --timeout 10m

# ---------------------------------------------------------------------------
# Step 5: apply the ECR creds refresh CronJob and the root Application
# ---------------------------------------------------------------------------
echo "[5/5] Applying ECR creds CronJob and root Application..."

# Wait for ArgoCD CRDs before applying the Application resource.
kubectl wait --for=condition=Established \
  --timeout=120s \
  crd/applications.argoproj.io

kubectl apply -f "${WORKDIR}/ecr-creds-sync.yaml"
kubectl apply -f "${WORKDIR}/root-app.yaml"

echo ""
echo "ArgoCD is up. Initial admin password:"
echo "  kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d"
echo ""
echo "Access the UI after DNS phase 2 is applied:"
echo "  https://argocd.<your-domain>"
