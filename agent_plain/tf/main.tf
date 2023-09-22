  terraform {
    backend "local" {
      path = "default.tfstate"
    }
  }

  provider "aws" {
    region = var.region
  }


  locals {
    env_content = file("../.env")
  }


  resource "aws_instance" "clearml_agent" {
    ami           = "ami-0648880541a3156f7"
    instance_type = var.instance_type
    
    key_name = var.key_name

    vpc_security_group_ids = [var.security_group_id]

    ebs_block_device {
      device_name = "/dev/xvda"
      volume_type = "gp3"
      volume_size = 20
    }

    user_data = <<-EOF
                #!/bin/bash

                # Log file for debugging
                exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

                # Convert .env content into environment variables and export them
                echo "${local.env_content}" > /tmp/.env

                while IFS='=' read -r key value; do
                    # Skip empty lines or lines without '='
                    if [[ -z "$key" || -z "$value" ]]; then
                        continue
                    fi

                    # Using printf to safely handle values with special characters
                    export "$key=$(printf '%q' "$value")"
                done < /tmp/.env

                sudo yum update -y
                sudo yum install -y python3-pip
                sudo pip install --upgrade pip
                sudo pip install clearml-agent==${var.clearml_agent_update_version}

                sudo python3 -m clearml_agent daemon --force-current-version --foreground
                EOF


    tags = {
      Name = var.instance_name
    }
  }