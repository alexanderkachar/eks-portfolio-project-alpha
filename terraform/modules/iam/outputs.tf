output "cluster_role_arn" {
  description = "IAM role assumed by the EKS control plane."
  value       = aws_iam_role.cluster.arn
}

output "node_role_arn" {
  description = "IAM role attached to managed node group EC2 instances."
  value       = aws_iam_role.node.arn
}

output "ebs_csi_role_arn" {
  description = "Pod Identity role for the EBS CSI controller."
  value       = aws_iam_role.ebs_csi.arn
}
