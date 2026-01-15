#!/usr/bin/env bash
set -e

cd envs/aws

terraform init
terraform destroy -auto-approve
