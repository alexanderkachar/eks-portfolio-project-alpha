output "instance_id" {
  description = "Runner EC2 instance ID."
  value       = aws_instance.this.id
}

output "runner_role_arn" {
  description = "IAM role attached to the runner."
  value       = aws_iam_role.this.arn
}

output "kms_key_arn" {
  description = "KMS CMK that encrypts the GitHub PAT SSM parameter."
  value       = aws_kms_key.github_pat.arn
}

output "kms_alias" {
  description = "Friendly alias for the PAT KMS key. Pass this as `--key-id` when running `aws ssm put-parameter` to seed the PAT."
  value       = aws_kms_alias.github_pat.name
}

output "runner_pat_put_command" {
  description = "Copy-paste command to seed the GitHub PAT into SSM. Replace ghp_xxx with your actual token."
  value       = "aws ssm put-parameter --name ${var.pat_ssm_parameter_name} --type SecureString --value ghp_xxx --key-id ${aws_kms_alias.github_pat.name} --overwrite --region ${data.aws_region.current.name}"
}

output "security_group_id" {
  description = "Runner security group ID."
  value       = aws_security_group.this.id
}

output "ssm_session_command" {
  description = "Copy-paste command to start an SSM session into the runner for debugging."
  value       = "aws ssm start-session --target ${aws_instance.this.id} --region ${data.aws_region.current.name}"
}
