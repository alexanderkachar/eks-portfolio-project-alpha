output "ssm_parameter_prefix" {
  description = "SSM Parameter Store prefix where connection params + the master password live. Future ExternalSecret should select children of this path."
  value       = local.ssm_param_prefix
}

output "instance_endpoint" {
  description = "RDS instance endpoint (host:port). Debug only — workloads should read individual SSM params, not this output."
  value       = aws_db_instance.this.endpoint
  sensitive   = true
}

output "kms_key_arn" {
  description = "CMK used for RDS storage and the master-password SSM SecureString. The ESO Pod Identity role will need kms:Decrypt on this."
  value       = aws_kms_key.rds.arn
}

output "security_group_id" {
  description = "RDS security group. Reference if a debug pod or another workload needs to connect."
  value       = aws_security_group.this.id
}
