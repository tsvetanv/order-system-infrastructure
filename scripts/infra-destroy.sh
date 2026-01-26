#!/usr/bin/env bash
set -e

ENVIRONMENT="$1"

if [[ -z "$ENVIRONMENT" ]]; then
  echo "❌ Environment not specified."
  echo "Usage: ./infra-destroy.sh <environment>"
  echo "Example: ./infra-destroy.sh aws"
  echo "         ./infra-destroy.sh local"
  exit 1
fi

ENV_DIR="envs/${ENVIRONMENT}"

if [[ ! -d "$ENV_DIR" ]]; then
  echo "❌ Unknown environment: '${ENVIRONMENT}'"
  echo "Expected directory: ${ENV_DIR}"
  exit 1
fi

BACKEND_CONFIG="${ENV_DIR}/backend.hcl"
VARS_FILE="${ENV_DIR}/terraform.tfvars"

if [[ ! -f "$BACKEND_CONFIG" ]]; then
  echo " Missing backend config: ${BACKEND_CONFIG}"
  exit 1
fi

if [[ ! -f "$VARS_FILE" ]]; then
  echo " Missing tfvars file: ${VARS_FILE}"
  exit 1
fi

echo "  Destroying infrastructure for environment: ${ENVIRONMENT}"
echo "  Backend: ${BACKEND_CONFIG}"
echo "  Vars:    ${VARS_FILE}"
echo

terraform -chdir=terraform init -backend-config="../${BACKEND_CONFIG}"
terraform -chdir=terraform destroy -var-file="../${VARS_FILE}" -auto-approve

echo
echo " Infrastructure destroyed for environment: ${ENVIRONMENT}"
