#!/bin/bash

AGENT_MODE="agent_plain"  # Default value

function deploy_agent() {
  INSTANCE_NAME="clearml-agent-$1"
  STATE_DIR="${PWD}/${AGENT_MODE}/tf/states/${INSTANCE_NAME}"

  mkdir -p "${STATE_DIR}"

  cd ./${AGENT_MODE}/tf || exit

  terraform init -backend-config="path=${STATE_DIR}/${INSTANCE_NAME}.tfstate"

  if ! terraform validate; then
    echo "Terraform validation failed for ${INSTANCE_NAME}. Skipping..."
    cd - || exit
    return
  fi

  # Apply the Terraform configuration
  terraform apply -lock=false -auto-approve -var "instance_name=${INSTANCE_NAME}" -state="${STATE_DIR}/${INSTANCE_NAME}.tfstate"

  cd - || exit
}

export -f deploy_agent

NUM_AGENTS=0

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
seq 0 $(($NUM_AGENTS - 1)) | xargs -I {} -P $NUM_AGENTS bash -c 'deploy_agent "$@"' _ {}
