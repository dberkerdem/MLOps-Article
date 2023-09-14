#!/bin/bash

NUM_WORKER=${1:-1}

docker build -t clearml-agent-custom ./agent

for (( i=1; i<=$NUM_WORKER; i++ ))
do
  echo "Running iteration $i"
  docker run -it -d --rm --name clearml-agent-$i clearml-agent-custom
done
