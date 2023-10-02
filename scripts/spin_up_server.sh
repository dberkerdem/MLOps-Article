#!/bin/bash

set -e
set -u
set -o pipefail

function check_required_tools() {
    if ! command -v terraform &> /dev/null; then
        echo "Error: terraform is not installed or not in PATH."
        exit 1
    fi
}

function deploy_server() {
  SERVER_NAME="clearml-server"
  STATE_DIR="${PWD}/server/tf/states"

  mkdir -p "${STATE_DIR}"

  cd ./server/tf || exit

  terraform init -reconfigure -backend-config="path=${STATE_DIR}/clearml_server.tfstate"

  if ! terraform validate; then
    echo "Terraform validation failed for ${SERVER_NAME}. Exiting..."
    exit 1
  fi

  # Apply the Terraform configuration
  terraform apply -auto-approve -var-file="common.tfvars" -state="${STATE_DIR}/${SERVER_NAME}.tfstate"

  cd - || exit
}

check_required_tools
deploy_server
