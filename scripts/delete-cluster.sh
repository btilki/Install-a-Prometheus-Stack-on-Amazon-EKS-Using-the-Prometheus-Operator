#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="prometheus-demo"

if ! command -v eksctl >/dev/null 2>&1; then
  echo "eksctl not found. Install from https://eksctl.io/"
  exit 1
fi

read -p "This will delete EKS cluster '${CLUSTER_NAME}'. Continue? (y/N) " yn
case "$yn" in
  [yY][eE][sS]|[yY]) ;;
  *) echo "Aborted."; exit 1;;
esac

eksctl delete cluster --name "${CLUSTER_NAME}"