#!/usr/bin/env bash

set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
REGISTRY="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
MIRROR_PLATFORMS="${MIRROR_PLATFORMS:-linux/amd64}"
MIRROR_RETRIES="${MIRROR_RETRIES:-4}"
MIRROR_RETRY_DELAY_SECONDS="${MIRROR_RETRY_DELAY_SECONDS:-20}"

IMAGES=(
  # Argo CD chart 8.1.2 defaults.
  "quay.io/argoproj/argocd:v3.0.6=mirror/argoproj/argocd:v3.0.6"
  "public.ecr.aws/docker/library/redis:7.2.8-alpine=mirror/argoproj/redis:7.2.8-alpine"
  "ghcr.io/dexidp/dex:v2.43.1=mirror/argoproj/dex:v2.43.1"

  # AWS Load Balancer Controller chart 1.13.0 default.
  "public.ecr.aws/eks/aws-load-balancer-controller:v2.13.0=mirror/kubernetes-sigs/aws-load-balancer-controller:v2.13.0"

  # External Secrets Operator chart 0.10.4 default.
  "oci.external-secrets.io/external-secrets/external-secrets:v0.10.4=mirror/external-secrets/external-secrets:v0.10.4"

  # kube-prometheus-stack chart 66.2.1 defaults.
  "quay.io/prometheus/prometheus:v2.55.1=mirror/prometheus-community/prometheus:v2.55.1"
  "quay.io/prometheus/alertmanager:v0.27.0=mirror/prometheus-community/alertmanager:v0.27.0"
  "quay.io/prometheus/node-exporter:v1.8.2=mirror/prometheus-community/node-exporter:v1.8.2"
  "registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.14.0=mirror/kube-state-metrics/kube-state-metrics:v2.14.0"
  "docker.io/grafana/grafana:11.3.0=mirror/grafana/grafana:11.3.0"
  "quay.io/prometheus-operator/prometheus-operator:v0.78.1=mirror/prometheus-operator/prometheus-operator:v0.78.1"
  "quay.io/prometheus-operator/prometheus-config-reloader:v0.78.1=mirror/prometheus-operator/prometheus-config-reloader:v0.78.1"
  "quay.io/kiwigrid/k8s-sidecar:1.28.0=mirror/kiwigrid/k8s-sidecar:1.28.0"
  "registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20221220-controller-v1.5.1-58-g787ea74b6=mirror/ingress-nginx/kube-webhook-certgen:v20221220-controller-v1.5.1-58-g787ea74b6"
  "docker.io/bats/bats:v1.4.1=mirror/bats/bats:v1.4.1"
  "docker.io/library/busybox:1.31.1=mirror/dockerhub/busybox:1.31.1"
)

login_ecr() {
  aws ecr get-login-password --region "$REGION" \
    | docker login --username AWS --password-stdin "$REGISTRY"
}

require_buildx() {
  if ! docker buildx version >/dev/null 2>&1; then
    printf 'ERROR: docker buildx is required for registry-to-registry mirroring.\n' >&2
    return 1
  fi
}

image_exists_in_ecr() {
  local repo="$1" tag="$2"
  aws ecr describe-images \
    --region "$REGION" \
    --repository-name "$repo" \
    --image-ids imageTag="$tag" \
    >/dev/null 2>&1
}

mirror_one() {
  local src="$1" dest="$2"
  local repo="${dest%:*}"
  local tag="${dest##*:}"
  local target="${REGISTRY}/${dest}"
  local sources=("$src")

  if image_exists_in_ecr "$repo" "$tag"; then
    printf '[skip] %s:%s already in ECR\n' "$repo" "$tag"
    return 0
  fi

  if [[ "$src" == public.ecr.aws/docker/library/* ]]; then
    sources+=("docker.io/library/${src#public.ecr.aws/docker/library/}")
  fi

  for src in "${sources[@]}"; do
    if copy_with_retries "$src" "$target"; then
      return 0
    fi
    printf '[fallback] %s failed\n' "$src" >&2
  done

  printf 'ERROR: failed to mirror %s to %s\n' "$1" "$target" >&2
  return 1
}

copy_with_retries() {
  local src="$1" target="$2"
  local attempt=1
  local platform_args=()

  if [[ -n "$MIRROR_PLATFORMS" ]]; then
    platform_args=(--platform "$MIRROR_PLATFORMS")
  fi

  while true; do
    printf '[copy] %s -> %s' "$src" "$target"
    if [[ -n "$MIRROR_PLATFORMS" ]]; then
      printf ' (%s)' "$MIRROR_PLATFORMS"
    fi
    printf '\n'

    if docker buildx imagetools create \
      --progress plain \
      "${platform_args[@]}" \
      --tag "$target" \
      "$src"; then
      return 0
    fi

    if (( attempt >= MIRROR_RETRIES )); then
      return 1
    fi

    printf '[retry] %s failed, retrying in %ss (%d/%d)\n' \
      "$src" "$MIRROR_RETRY_DELAY_SECONDS" "$attempt" "$MIRROR_RETRIES" >&2
    sleep "$MIRROR_RETRY_DELAY_SECONDS"
    attempt=$((attempt + 1))
  done
}

main() {
  require_buildx
  login_ecr
  local mirrored=0
  local src dest
  for entry in "${IMAGES[@]}"; do
    src="${entry%%=*}"
    dest="${entry#*=}"
    mirror_one "$src" "$dest"
    ((mirrored++)) || true
  done
  printf 'Done. Processed %d image(s).\n' "$mirrored"
}

main "$@"
