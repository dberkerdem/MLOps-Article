terraform {
  backend "local" {
    path = "default.tfstate"
  }
}

provider "aws" {
  region = var.region
}

data "aws_iam_role" "existing_role" {
  name = "ec2-role-for-s3-read-only"
}

resource "aws_iam_instance_profile" "profile" {
  name = format("%s_iam_instance_profile", var.instance_name)
  role = data.aws_iam_role.existing_role.name
}

resource "aws_instance" "clearml_agent" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [var.security_group_id]

  iam_instance_profile = aws_iam_instance_profile.profile.name

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_type = "gp3"
    volume_size = 10
  }

  user_data = <<-EOF
              #!/bin/bash
              # Log
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

              aws s3 cp ${var.clearml_config_s3_uri} ${var.clearml_conf_path}
              chmod 600 ${var.clearml_conf_path}

              sudo yum update -y
              sudo yum install gcc gcc-c++ -y
              export CC=$(which gcc)
              export CXX=$(which g++)
              sudo yum install -y git
              export PATH=$PATH:/usr/bin
              sudo yum install -y python3-pip
              sudo pip install --upgrade pip
              sudo pip install clearml-agent==${var.clearml_agent_update_version}
              
              export CLEARML_WORKER_NAME=${var.instance_name}
              
              sudo python3 -m clearml_agent daemon --force-current-version --foreground --queue ${var.clearml_agent_queue} --config-file ${var.clearml_conf_path}
              EOF

  tags = {
    Name = var.instance_name
  }
}
