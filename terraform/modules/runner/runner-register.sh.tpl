#!/bin/bash

set -eu

cd /opt/actions-runner

PAT=$(aws ssm get-parameter \
  --name "${pat_ssm_parameter_name}" \
  --with-decryption \
  --query Parameter.Value \
  --output text)

REG_TOKEN=$(curl -sS -X POST \
  -H "Authorization: token $PAT" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/${github_owner}/${github_repo}/actions/runners/registration-token" \
  | jq -r .token)

./config.sh remove --token "$REG_TOKEN" 2>/dev/null || true

./config.sh \
  --url "https://github.com/${github_owner}/${github_repo}" \
  --token "$REG_TOKEN" \
  --name "vpc-runner-$(hostname)-$(date +%s)" \
  --labels "self-hosted,linux,x64,vpc" \
  --unattended \
  --ephemeral \
  --replace
