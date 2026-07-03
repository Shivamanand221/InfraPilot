#!/usr/bin/env bash

set -e  

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$SCRIPT_DIR/../terraform/environments/dev"
OUTPUT_NAME="instance_public_ip"
GH_SECRET_NAME="EC2_HOST"
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

command -v terraform >/dev/null 2>&1 || {
    echo "❌ Terraform is not installed."
    exit 1
}

command -v gh >/dev/null 2>&1 || {
    echo "❌ GitHub CLI is not installed."
    exit 1
}

if ! gh auth status >/dev/null 2>&1; then
    echo "❌ GitHub CLI is not authenticated."
    echo "Run: gh auth login"
    exit 1
fi

cd "$TF_DIR"

echo "Fetching  '$OUTPUT_NAME' from Terraform outputs"
INSTANCE_IP=$(terraform output -raw "$OUTPUT_NAME" 2>/dev/null || true)

if [[ -z "$INSTANCE_IP" ]]; then
    echo "Error: Could not retrieve '$OUTPUT_NAME' from Terraform."
  exit 1
fi

echo "Updating GitHub secret '$GH_SECRET_NAME'..."

gh secret set "$GH_SECRET_NAME" \
    --body "$INSTANCE_IP" \
    --repo "$REPO"

echo "✅ GitHub Secret updated successfully."
cd -