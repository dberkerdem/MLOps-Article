#!/bin/bash

NUM_AGENTS=0

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --num-agents)
            NUM_AGENTS="$2"
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

for i in $(seq 0 $(($NUM_AGENTS - 1))); do
  # Define the instance name based on the loop index
  INSTANCE_NAME="clearml-worker-$i"

  # Navigate to the directory containing the Terraform files
  cd ./agent/tf

  # Initialize Terraform
  terraform init

  # Validate the Terraform files
  terraform validate

  # Apply the Terraform configuration
  terraform apply -auto-approve -var "instance_name=${INSTANCE_NAME}"

  # Navigate back to the original directory (important if you're running this in a loop)
  cd -
done
