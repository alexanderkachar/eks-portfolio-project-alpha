#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"

REGION="${AWS_REGION:-us-east-1}"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
REGISTRY="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
IMAGE_TAG="${IMAGE_TAG:-dev}"

login_ecr() {
  aws ecr get-login-password --region "$REGION" \
    | docker login --username AWS --password-stdin "$REGISTRY"
}

image_exists_in_ecr() {
  local repo="$1" tag="$2"
  aws ecr describe-images \
    --region "$REGION" \
    --repository-name "$repo" \
    --image-ids imageTag="$tag" \
    >/dev/null 2>&1
}

build_and_push() {
  local name="$1"
  local context="$2"
  local dockerfile="${3:-}"
  local image="${REGISTRY}/${name}:${IMAGE_TAG}"
  local dockerfile_args=()

  if image_exists_in_ecr "$name" "$IMAGE_TAG"; then
    printf '[skip]  %s already exists in ECR\n' "$image"
    return 0
  fi

  if [[ -n "$dockerfile" ]]; then
    dockerfile_args=(-f "$dockerfile")
  fi

  printf '[build] %s from %s\n' "$image" "$context"
  docker build "${dockerfile_args[@]}" -t "$image" "$context"

  printf '[push]  %s\n' "$image"
  docker push "$image"
}

login_ecr
build_and_push "todo-backend" "${REPO_ROOT}/apps/backend" "${REPO_ROOT}/apps/backend/src/Dockerfile"
build_and_push "todo-frontend" "${REPO_ROOT}/apps/frontend"

printf 'Done. Pushed todo app images with tag %s.\n' "$IMAGE_TAG"
