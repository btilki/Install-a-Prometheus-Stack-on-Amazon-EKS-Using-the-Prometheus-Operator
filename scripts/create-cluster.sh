#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG="${DIR}/../eksctl/create-cluster.yaml"

if ! command -v eksctl >/dev/null 2>&1; then
  echo "eksctl not found. Install from https://eksctl.io/"
  exit 1
fi

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl not found. Install from https://kubernetes.io/docs/tasks/tools/"
  exit 1
fi

echo "Creating EKS cluster using config: ${CFG}"
eksctl create cluster -f "${CFG}"

echo
echo "Cluster create initiated (or completed). Please verify with:"
echo "  kubectl get nodes"
echo
echo "Next, add Helm repos and install the kube-prometheus-stack chart:"
echo "  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts"
echo "  helm repo update"
echo "  helm install prometheus-stack prometheus-community/kube-prometheus-stack -f helm/values-prometheus.yaml --namespace monitoring --create-namespace"