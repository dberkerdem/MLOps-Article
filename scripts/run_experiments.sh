#!/bin/bash

log_file="./logs/experiments.log"

n_tasks=$1
num_worker=$2

if [ -z "$n_tasks" ]; then
  echo "Please provide the number of tasks to run."
  exit 1
fi

if [ -z "$num_worker" ]; then
  echo "Please provide the number of active workers."
  exit 1
fi

echo "Experiments with $num_worker workers triggered at $(date)" >>$log_file

for i in $(seq 1 $n_tasks); do
  clearml-task --project LoadTest --name LGBExample --repo https://github.com/dberkerdem/MLOps-Article.git --branch main --script /task/from_repo/lgb_task/lightgbm_example.py --queue default
#  clearml-task --project LoadTest --name MNISTExample --repo https://github.com/dberkerdem/MLOps-Article.git --branch main --script /task/from_repo/mnist_task/main.py --queue default
done
