# Private EKS Portfolio Project

A fully private, GitOps-driven EKS cluster hosting a React/Node/Postgres todo app, with Grafana and ArgoCD on sibling subdomains. Every component runs in private subnets. The Kubernetes API is unreachable from the public internet. Nodes reach AWS exclusively through VPC endpoints — no NAT gateway for cluster traffic. CI runs on a self-hosted GitHub Actions runner inside the VPC. Deployment is GitOps — ArgoCD pulls Helm charts from ECR OCI.

**Purpose:** portfolio / interview demo. Infrastructure is created and destroyed per session.