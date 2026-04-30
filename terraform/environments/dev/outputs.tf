output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private (cluster) subnet IDs."
  value       = module.vpc.private_subnet_ids
}

output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint (private)."
  value       = module.eks.cluster_endpoint
}

output "cluster_arn" {
  description = "EKS cluster ARN."
  value       = module.eks.cluster_arn
}

output "kubeconfig_command" {
  description = "Run this from inside the VPC (e.g. a bastion) to get kubectl access."
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
}

output "bastion_instance_id" {
  description = "Bastion EC2 instance ID."
  value       = module.bastion.instance_id
}

output "bastion_ssm_session_command" {
  description = "Copy-paste command to start an SSM session into the bastion."
  value       = module.bastion.ssm_session_command
}

output "rds_ssm_parameter_prefix" {
  description = "SSM Parameter Store prefix where RDS connection params + master password live."
  value       = module.rds.ssm_parameter_prefix
}

output "rds_kms_key_arn" {
  description = "RDS storage CMK ARN."
  value       = module.rds.kms_key_arn
}

output "ecr_registry_url" {
  description = "ECR registry URL prefix (account.dkr.ecr.region.amazonaws.com)."
  value       = module.ecr.registry_url
}

output "ecr_repository_urls" {
  description = "Map of ECR repository name → fully-qualified URL."
  value       = module.ecr.repository_urls
}

output "runner_instance_id" {
  description = "GitHub Actions runner EC2 instance ID."
  value       = module.runner.instance_id
}

output "runner_kms_alias" {
  description = "KMS alias for the GitHub PAT. Pass to `aws ssm put-parameter --key-id` when seeding the PAT."
  value       = module.runner.kms_alias
}

output "runner_pat_put_command" {
  description = "Copy-paste command to seed the GitHub PAT into SSM. Replace ghp_xxx with your actual token."
  value       = module.runner.runner_pat_put_command
}
