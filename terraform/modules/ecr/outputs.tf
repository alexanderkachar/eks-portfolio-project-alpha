output "registry_id" {
  description = "ECR registry ID (= AWS account ID). Same value for every repo in the account."
  value       = data.aws_caller_identity.current.account_id
}

output "registry_url" {
  description = "ECR registry URL prefix. Repository URLs are this followed by '/<name>'."
  value       = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
}

output "repository_urls" {
  description = "Map of repository name → fully-qualified ECR URL (registry/name)."
  value       = { for k, v in aws_ecr_repository.this : k => v.repository_url }
}

output "repository_arns" {
  description = "Map of repository name → ARN. Use for scoping IAM policies (runner push, ArgoCD pull)."
  value       = { for k, v in aws_ecr_repository.this : k => v.arn }
}

data "aws_region" "current" {}
