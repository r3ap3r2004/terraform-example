#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

regions=(us-east-1 us-east-2 us-west-1 us-west-2)
echo "Select a region to deploy:"
select region in "${regions[@]}"; do
  [[ -n "$region" ]] && break
done

cd environments/"$region"
terraform init -input=false
terraform workspace select "$region" 2>/dev/null || terraform workspace new "$region"

read -p "Are you sure you wish to destroy all resources? (y/N): " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
  terraform destroy -var-file=terraform.tfvars
else
  echo "Aborted."
fi
