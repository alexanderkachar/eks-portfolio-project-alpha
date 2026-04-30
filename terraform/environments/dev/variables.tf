variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short project identifier used in resource names and tags."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "admin_principal_arn" {
  description = "IAM principal ARN granted cluster-admin via access entry (e.g. the ARN of the IAM user or role you run terraform / kubectl as)."
  type        = string
}

variable "cluster_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.35"
}

variable "github_owner" {
  description = "GitHub owner (user or org) for the repo the runner registers against."
  type        = string
}
