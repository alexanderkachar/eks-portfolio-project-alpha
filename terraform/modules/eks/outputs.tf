output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "EKS cluster ARN."
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "EKS API server endpoint (private)."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_ca_data" {
  description = "Base64-encoded cluster CA certificate."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL for the cluster. Exposed for completeness — not used because Pod Identity replaces IRSA."
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "node_security_group_id" {
  description = "Security group attached to managed node group instances by EKS."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "secrets_kms_key_arn" {
  description = "KMS CMK used for Kubernetes secret envelope encryption."
  value       = aws_kms_key.secrets.arn
}
