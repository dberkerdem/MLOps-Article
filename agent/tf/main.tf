provider "aws" {
  region = var.region
}

locals {
  env_content = file("../.env")
}

resource "aws_instance" "my_instance" {
  ami           = "ami-0648880541a3156f7"
  instance_type = var.instance_type
  
  key_name = var.key_name

  vpc_security_group_ids = [var.security_group_id]

  user_data = <<-EOF
    #!/bin/bash

    # Log file for debugging
    exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

    sudo yum update -y
    sudo yum install docker -y
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    sudo chkconfig docker on
    sudo yum install -y git

    # Clone the repo
    git clone ${var.repo_url}
    if [ $? -ne 0 ]; then
        echo "Failed to clone the repo"
        exit 1
    fi

    cd MLOps-Article
    echo '${local.env_content}' > ./agent/.env

    sudo chmod +x scripts/*
    ./scripts/run_workers.sh --num-workers 1 --image-name dberkerdem/clearml-agent-custom
  EOF


  tags = {
    Name = var.instance_name
  }
}