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

echo "----- Terraform Plan for $region -----"
terraform plan -var-file=terraform.tfvars

read -p "Apply the above changes? (y/N): " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
  terraform apply -var-file=terraform.tfvars -auto-approve
else
  echo "Aborted."
fi
