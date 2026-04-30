variable "project_name" {
  description = "Short project identifier (used in tags)."
  type        = string
}

variable "environment" {
  description = "Environment name (used in tags)."
  type        = string
}

variable "repository_names" {
  description = "ECR repository names to create. Each value becomes the repository name verbatim."
  type        = list(string)
  default = [
    # Application images.
    "todo-frontend",
    "todo-backend",

    # OCI Helm charts authored in this repo.
    "charts/todo",

    # Mirrored third-party container images (GitOps + platform stack).
    "mirror/argoproj/argocd",
    "mirror/argoproj/redis",
    "mirror/argoproj/dex",
    "mirror/kubernetes-sigs/aws-load-balancer-controller",
    "mirror/external-secrets/external-secrets",
    "mirror/prometheus-community/prometheus",
    "mirror/prometheus-community/alertmanager",
    "mirror/prometheus-community/node-exporter",
    "mirror/kube-state-metrics/kube-state-metrics",
    "mirror/grafana/grafana",
    "mirror/prometheus-operator/prometheus-operator",

    # Mirrored third-party Helm charts.
    "charts/mirror/argocd",
    "charts/mirror/aws-load-balancer-controller",
    "charts/mirror/external-secrets",
    "charts/mirror/kube-prometheus-stack",
  ]
}

variable "untagged_image_expiry_days" {
  description = "Days after push before untagged images are expired by lifecycle policy."
  type        = number
  default     = 7
}

variable "tagged_image_retention_count" {
  description = "How many tagged images to keep per repository before older tagged images are expired."
  type        = number
  default     = 10
}
