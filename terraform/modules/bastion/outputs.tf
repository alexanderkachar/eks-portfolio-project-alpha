output "instance_id" {
  description = "Bastion EC2 instance ID. Pair with `aws ssm start-session --target <id>`."
  value       = aws_instance.this.id
}

output "instance_role_arn" {
  description = "IAM role ARN attached to the bastion (cluster-admin via access entry)."
  value       = aws_iam_role.this.arn
}

output "security_group_id" {
  description = "Bastion security group ID."
  value       = aws_security_group.this.id
}

output "private_ip" {
  description = "Bastion private IPv4. Useful for debugging routing/SG issues."
  value       = aws_instance.this.private_ip
}

output "ssm_session_command" {
  description = "Copy-paste command to start an SSM session into the bastion."
  value       = "aws ssm start-session --target ${aws_instance.this.id} --region ${var.region}"
}
