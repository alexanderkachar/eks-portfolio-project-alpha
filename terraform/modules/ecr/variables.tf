variable "project_name" {
  description = "Short project identifier (used in tags)."
  type        = string
}

variable "environment" {
  description = "Environment name (used in tags)."
  type        = string
}

variable "repository_names" {
  description = "ECR repository names to create. Each value becomes the repository name verbatim. Default seed list comes from CLAUDE.md §6.3 — todo app images, mirrored third-party images, and OCI Helm chart repositories."
  type        = list(string)
  default = [
    # Application images.
    "todo-frontend",
    "todo-backend",

    # OCI Helm charts authored in this repo.
    "charts/todo",
    "charts/platform",

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
    "mirror/prometheus-operator/prometheus-config-reloader",
    "mirror/kiwigrid/k8s-sidecar",
    "mirror/ingress-nginx/kube-webhook-certgen",
    "mirror/bats/bats",
    "mirror/dockerhub/busybox",

    # Mirrored third-party Helm charts. Names must match each chart's
    # internal name from Chart.yaml — `helm push` derives the OCI path
    # from that, not the file name. Upstream argo-cd chart uses a hyphen.
    "charts/mirror/argo-cd",
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
