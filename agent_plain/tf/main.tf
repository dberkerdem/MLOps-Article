  terraform {
    backend "local" {
      path = "default.tfstate"
    }
  }

  provider "aws" {
    region = var.region
  }

  locals {
    env_content_lines = [for line in split("\n", file("../.env")) : 
                          starts_with(line, "#") || length(trim(line)) == 0 ? "" : "export ${line}"
                        ]
    env_content = join("\n", local.env_content_lines)
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

                export '${local.env_content}'

                sudo yum update -y
                sudo yum install -y python3-pip
                sudo pip3 install --upgrade pip==${PIP_UPDATE_VERSION}
                sudo pip3 install clearml-agent==${CLEARML_AGENT_UPDATE_VERSION}

                sudo python3 -m clearml_agent daemon --force-current-version --detached
                EOF

    tags = {
      Name = var.instance_name
    }
  }