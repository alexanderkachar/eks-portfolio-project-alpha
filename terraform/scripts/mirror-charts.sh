#!/usr/bin/env bash

set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
REGISTRY="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

CHARTS=(
  "https://argoproj.github.io/argo-helm|argo-cd|8.1.2|charts/mirror"
  "https://aws.github.io/eks-charts|aws-load-balancer-controller|1.13.0|charts/mirror"
  "https://charts.external-secrets.io|external-secrets|0.10.4|charts/mirror"
  "https://prometheus-community.github.io/helm-charts|kube-prometheus-stack|66.2.1|charts/mirror"
)

login_helm() {
  aws ecr get-login-password --region "$REGION" \
    | helm registry login --username AWS --password-stdin "$REGISTRY"
}

chart_exists_in_ecr() {
  local repo="$1" version="$2"
  aws ecr describe-images \
    --region "$REGION" \
    --repository-name "$repo" \
    --image-ids imageTag="$version" \
    >/dev/null 2>&1
}

mirror_one() {
  local repo_url="$1" chart="$2" version="$3" dest_path="$4"
  local ecr_repo="${dest_path}/${chart}"

  if chart_exists_in_ecr "$ecr_repo" "$version"; then
    printf '[skip] %s:%s already in ECR\n' "$ecr_repo" "$version"
    return 0
  fi

  printf '[pull] %s %s from %s\n' "$chart" "$version" "$repo_url"
  helm pull "$chart" \
    --repo "$repo_url" \
    --version "$version" \
    --destination "$WORKDIR"

  local tgz="${WORKDIR}/${chart}-${version}.tgz"
  if [[ ! -f "$tgz" ]]; then
    printf 'ERROR: helm pull did not produce %s\n' "$tgz" >&2
    return 1
  fi

  printf '[push] %s -> oci://%s/%s\n' "$tgz" "$REGISTRY" "$dest_path"
  helm push "$tgz" "oci://${REGISTRY}/${dest_path}"
}

main() {
  login_helm
  local mirrored=0
  for entry in "${CHARTS[@]}"; do
    IFS='|' read -r repo_url chart version dest_path <<<"$entry"
    mirror_one "$repo_url" "$chart" "$version" "$dest_path"
    ((mirrored++)) || true
  done
  printf 'Done. Processed %d chart(s).\n' "$mirrored"
}

main "$@"
