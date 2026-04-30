variable "project_name" {
  description = "Short project identifier."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "db_subnet_ids" {
  description = "Database subnet IDs (private, no egress) for the DB subnet group."
  type        = list(string)
}

variable "cluster_security_group_id" {
  description = "EKS cluster security group. Inbound 5432 to RDS is allowed only from this SG (cluster nodes are members)."
  type        = string
}

variable "engine_version" {
  description = "Postgres engine version. Pin to a specific minor (e.g. 16.6) so apply doesn't drift when AWS publishes new patch versions."
  type        = string
  default     = "16.6"
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage_gb" {
  description = "Allocated storage in GB."
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "todo"
}

variable "master_username" {
  description = "Master DB username."
  type        = string
  default     = "todo_admin"
}
