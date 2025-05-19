#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Check for OpenTofu first, fall back to Terraform
if command -v tofu >/dev/null 2>&1; then
  echo "Using OpenTofu"
  CMD=tofu
elif command -v terraform >/dev/null 2>&1; then
  echo "OpenTofu not found, using Terraform"
  CMD=terraform
else
  echo "Error: Neither OpenTofu nor Terraform is installed. Please install one of them."
  exit 1
fi

regions=(us-east-1 us-east-2 us-west-1 us-west-2)
echo "Select a region to deploy:"
select region in "${regions[@]}"; do
  [[ -n "$region" ]] && break
done

cd environments/"$region"
$CMD init -input=false
$CMD workspace select "$region" 2>/dev/null || $CMD workspace new "$region"

echo "----- ${CMD^} Plan for $region -----"
$CMD plan -var-file=terraform.tfvars

read -p "Apply the above changes? (y/N): " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
  $CMD apply -var-file=terraform.tfvars -auto-approve
else
  echo "Aborted."
fi
