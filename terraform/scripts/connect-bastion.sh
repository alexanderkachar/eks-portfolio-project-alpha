#!/usr/bin/env bash

set -euo pipefail

NAME_TAG="${BASTION_NAME:-project-alpha-dev-bastion}"
REGION="${AWS_REGION:-us-east-1}"

INSTANCE_ID=$(aws ec2 describe-instances \
  --region "$REGION" \
  --filters \
    "Name=tag:Name,Values=$NAME_TAG" \
    "Name=instance-state-name,Values=running" \
  --query 'Reservations[0].Instances[0].InstanceId' \
  --output text)

if [[ -z "$INSTANCE_ID" || "$INSTANCE_ID" == "None" ]]; then
  echo "No running bastion found with Name=$NAME_TAG in $REGION." >&2
  exit 1
fi

echo "Connecting to $INSTANCE_ID ($NAME_TAG, $REGION) as ec2-user..." >&2
exec aws ssm start-session \
  --target "$INSTANCE_ID" \
  --region "$REGION" \
  --document-name AWS-StartInteractiveCommand \
  --parameters 'command=["sudo -iu ec2-user"]'
