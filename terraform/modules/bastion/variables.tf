variable "project_name" {
  description = "Short project identifier."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "region" {
  description = "AWS region. Templated into user-data so kubeconfig points at the right cluster endpoint."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR. Used for HTTPS egress scoping."
  type        = string
}

variable "subnet_id" {
  description = "Subnet to launch the bastion into. Must have internet egress (e.g. via NAT) for the user-data tool downloads to succeed. See README."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name. Used by user-data (update-kubeconfig) and by the access entry."
  type        = string
}

variable "cluster_arn" {
  description = "EKS cluster ARN. Used to scope the bastion role's eks:DescribeCluster permission."
  type        = string
}

variable "cluster_security_group_id" {
  description = "EKS cluster security group. The bastion needs an ingress rule on this SG to reach the private API endpoint on 443."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size_gb" {
  description = "Root EBS volume size."
  type        = number
  default     = 20
}
