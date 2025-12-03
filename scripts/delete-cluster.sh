#!/usr/bin/env bash
set -euo pipefail  # Exit on error, undefined variable, or failed pipe

CLUSTER_NAME="prometheus-demo"  # Name of the EKS cluster to delete

# Check if eksctl is installed
if ! command -v eksctl >/dev/null 2>&1; then
  echo "eksctl not found. Install from https://eksctl.io/"
  exit 1
fi

# Prompt user for confirmation before deleting the cluster
read -p "This will delete EKS cluster '${CLUSTER_NAME}'. Continue? (y/N) " yn
case "$yn" in
  [yY][eE][sS]|[yY]) ;;  # Proceed if user types yes or y
  *) echo "Aborted."; exit 1;;  # Exit otherwise
esac

# Delete the EKS cluster
eksctl delete cluster --name "${CLUSTER_NAME}" 
