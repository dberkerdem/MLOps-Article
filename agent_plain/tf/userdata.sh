#!/bin/bash

# Log
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Copy clearml.conf
aws s3 cp ${clearml_config_s3_uri} ${clearml_conf_path}
chmod 600 ${clearml_conf_path}
sudo sed -i 's/^    worker_id: ""$/    worker_id: "'${instance_name}'"/' ${clearml_conf_path}
sudo sed -i 's/^    worker_name: ""$/    worker_name: "'${instance_name}'"/' ${clearml_conf_path}

sudo yum update -y
sudo yum install gcc gcc-c++ cmake -y
export CC=$(which gcc)
export CXX=$(which g++)
sudo yum install -y git
export PATH=$PATH:/usr/bin
sudo yum install -y python3-pip
sudo pip install --upgrade pip
sudo pip install clearml-agent==${clearml_agent_update_version}

sudo python3 -m clearml_agent daemon --force-current-version --detached --queue ${clearml_agent_queue}