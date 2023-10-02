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

function destroy_server() {
  SERVER_NAME="clearml-server"
  STATE_DIR="${PWD}/server/tf/states"

  cd ./server/tf || exit

  # Ensure the correct state file is used
  if [ ! -f "${STATE_DIR}/${SERVER_NAME}.tfstate" ]; then
    echo "State file for ${SERVER_NAME} not found. Exiting..."
    exit 1
  fi

  terraform init -reconfigure -backend-config="path=${STATE_DIR}/clearml_server.tfstate"

  # Destroy the Terraform configuration
  terraform destroy -auto-approve -var-file="common.tfvars" -state="${STATE_DIR}/${SERVER_NAME}.tfstate"

  cd - || exit
}

check_required_tools
destroy_server
