variable "project_name" {
  description = "Short project identifier."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "cluster_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.32"
}

variable "subnet_ids" {
  description = "Private subnet IDs for the cluster control plane and node group."
  type        = list(string)
}

variable "cluster_role_arn" {
  description = "IAM role ARN for the EKS control plane."
  type        = string
}

variable "node_role_arn" {
  description = "IAM role ARN attached to managed node group instances."
  type        = string
}

variable "ebs_csi_role_arn" {
  description = "Pod Identity role ARN for the EBS CSI controller."
  type        = string
}

variable "admin_principal_arn" {
  description = "IAM principal granted cluster-admin via access entry. Must be set for the operator to kubectl into the cluster."
  type        = string
}

variable "node_instance_types" {
  description = "Instance types for the managed node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired node count."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum node count."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum node count."
  type        = number
  default     = 3
}

variable "cluster_log_retention_days" {
  description = "Retention for the cluster's CloudWatch log group."
  type        = number
  default     = 30
}
