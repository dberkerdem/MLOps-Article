  terraform {
    backend "local" {
      path = "default.tfstate"
    }
  }

  provider "aws" {
    region = var.region
  }

  data "aws_secretsmanager_secret_version" "my_secret" {
    secret_id = "name_or_arn_of_your_secret"
  }
  locals {
    clearml_conf = file("../clearml.conf")
  }


  resource "aws_instance" "clearml_agent" {
    ami           = "ami-0648880541a3156f7"
    instance_type = var.instance_type
    
    key_name = var.key_name

    vpc_security_group_ids = [var.security_group_id]

    ebs_block_device {
      device_name = "/dev/xvda"
      volume_type = "gp3"
      volume_size = 10
    }

    user_data = <<-EOF
                #!/bin/bash

                # Log file for debugging
                exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

                # Convert .env content into environment variables and export them
                echo "${local.clearml_conf}" > /home/ec2-user/clearml.conf

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