#!/usr/bin/env bash
# Create a zip of the repository for download/upload to GitHub
set -euo pipefail

OUT="prometheus-eks-sample-$(date +%Y%m%d_%H%M%S).zip"
echo "Creating ${OUT} ..."
zip -r "${OUT}" . -x "*.git*" -x "node_modules/*" -x "*.zip"
echo "Created ${OUT}"