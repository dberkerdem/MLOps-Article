#!/bin/bash

IMAGE_NAME="clearml-agent-custom"

while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
    --image-name)
      IMAGE_NAME="$2"
      shift
      shift
      ;;
    *)
      shift
      ;;
  esac
done

docker build -t $IMAGE_NAME ./agent
