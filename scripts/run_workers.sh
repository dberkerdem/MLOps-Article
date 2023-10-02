#!/bin/bash

NUM_WORKER=1
IMAGE_NAME="clearml-agent-custom"

while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
    --num-workers)
      NUM_WORKER="$2"
      shift
      shift
      ;;
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

find_next_worker_number() {
  local n=1
  while docker container inspect clearml-agent-$n > /dev/null 2>&1; do
    let "n++"
  done
  echo $n
}

for (( i=1; i<=$NUM_WORKER; i++ ))
do
  next_worker_number=$(find_next_worker_number)
  worker_name="clearml-agent-$next_worker_number"
  echo "Running container with name $worker_name"
  docker run -it -d --rm --name $worker_name --env-file agent/.env -e CLEARML_WORKER_NAME=$worker_name $IMAGE_NAME
done
