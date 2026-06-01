#!/bin/bash
# ============================================================================
# Deploy Infrastructure Script
# ============================================================================
# Wrapper script for Terraform plan/apply with proper environment setup.
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="${SCRIPT_DIR}/../terraform"
ACTION="${1:-plan}"

show_help() {
  echo "Usage: $0 <action>"
  echo ""
  echo "Actions:"
  echo "  plan     - Run terraform plan"
  echo "  apply    - Run terraform apply"
  echo "  destroy  - Destroy all infrastructure"
  echo "  output   - Show all outputs"
  echo "  fmt      - Format terraform files"
  echo "  validate - Validate terraform configuration"
  echo ""
}

case "$ACTION" in
  plan)
    echo "=== Running Terraform Plan ==="
    cd "$TF_DIR"
    terraform init
    terraform plan -out=tfplan
    ;;
  apply)
    echo "=== Running Terraform Apply ==="
    cd "$TF_DIR"
    terraform init
    terraform apply tfplan 2>/dev/null || terraform apply
    echo ""
    echo "=== Deployment Summary ==="
    terraform output deployment_summary
    ;;
  destroy)
    echo "=== WARNING: This will DESTROY all infrastructure! ==="
    read -p "Type 'yes' to confirm: " CONFIRM
    if [ "$CONFIRM" = "yes" ]; then
      cd "$TF_DIR"
      terraform destroy
    else
      echo "Cancelled."
    fi
    ;;
  output)
    cd "$TF_DIR"
    terraform output deployment_summary
    ;;
  fmt)
    cd "$TF_DIR"
    terraform fmt -recursive
    ;;
  validate)
    cd "$TF_DIR"
    terraform init
    terraform validate
    ;;
  *)
    show_help
    exit 1
    ;;
esac
