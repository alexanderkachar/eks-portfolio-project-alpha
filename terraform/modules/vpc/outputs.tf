output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "VPC CIDR block."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs, ordered [AZ-a, AZ-b]."
  value       = [aws_subnet.this["public_a"].id, aws_subnet.this["public_b"].id]
}

output "runner_subnet_ids" {
  description = "Runner subnet IDs, ordered [AZ-a, AZ-b]."
  value       = [aws_subnet.this["runner_a"].id, aws_subnet.this["runner_b"].id]
}

output "private_subnet_ids" {
  description = "Private (cluster) subnet IDs, ordered [AZ-a, AZ-b]."
  value       = [aws_subnet.this["private_a"].id, aws_subnet.this["private_b"].id]
}

output "db_subnet_ids" {
  description = "Database subnet IDs, ordered [AZ-a, AZ-b]."
  value       = [aws_subnet.this["db_a"].id, aws_subnet.this["db_b"].id]
}

output "endpoints_security_group_id" {
  description = "Security group ID used by interface endpoints."
  value       = aws_security_group.endpoints.id
}
