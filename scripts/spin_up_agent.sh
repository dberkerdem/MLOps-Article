#!/bin/bash

function deploy_agent() {
  local mode="$1"
  local instance_number="$2"

  INSTANCE_NAME="clearml-agent-${instance_number}"
  STATE_DIR="${PWD}/${mode}/tf/states/${INSTANCE_NAME}"

  mkdir -p "${STATE_DIR}"

  cd ./${mode}/tf || exit

  terraform init -backend-config="path=${STATE_DIR}/${INSTANCE_NAME}.tfstate"

  if ! terraform validate; then
    echo "Terraform validation failed for ${INSTANCE_NAME}. Skipping..."
    cd - || exit
    return
  fi

  # Apply the Terraform configuration
  terraform apply -lock=false -auto-approve -var-file="common.tfvars" -var "instance_name=${INSTANCE_NAME}" -state="${STATE_DIR}/${INSTANCE_NAME}.tfstate"

  cd - || exit
}

export -f deploy_agent

NUM_AGENTS=0
AGENT_MODE="agent_plain"  # Default value

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --num-agents)
            NUM_AGENTS="$2"
            shift ;;
        --agent-mode)
            AGENT_MODE="$2"
            shift ;;
        *) 
            echo "Unknown parameter passed: $1"
            exit 1 ;;
    esac
    shift
done

if [ "$NUM_AGENTS" -eq 0 ]; then
  echo "Please specify the number of agents using --num-agents flag."
  exit 1
fi

# Use xargs to parallelize
seq 0 $(($NUM_AGENTS - 1)) | xargs -I {} -P $NUM_AGENTS bash -c 'deploy_agent "$@"' _ "${AGENT_MODE}" {}
