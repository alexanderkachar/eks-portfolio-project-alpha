#!/bin/bash
set -eux

dnf update -y
dnf install -y awscli git tar gzip

curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && mv kubectl /usr/local/bin/

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod +x get_helm.sh && ./get_helm.sh

curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd

install -d -m 755 /etc/eks
aws eks update-kubeconfig \
  --name ${cluster_name} \
  --region ${region} \
  --kubeconfig /etc/eks/kubeconfig
chmod 644 /etc/eks/kubeconfig

install -d -m 700 -o ec2-user -g ec2-user /home/ec2-user/.kube
ln -sf /etc/eks/kubeconfig /home/ec2-user/.kube/config
chown -R ec2-user:ec2-user /home/ec2-user/.kube

cat >/etc/profile.d/eks-kubeconfig.sh <<'EOF'
export KUBECONFIG="$${KUBECONFIG:-/etc/eks/kubeconfig}"
EOF
