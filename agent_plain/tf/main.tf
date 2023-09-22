terraform {
  backend "local" {
    path = "default.tfstate"
  }
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "clearml_agent" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [var.security_group_id]

  iam_instance_profile = var.iam_instance_profile

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_type = "gp3"
    volume_size = 10
  }

  user_data = <<-EOF
              #!/bin/bash
              # Log
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

              aws s3 cp ${var.clearml_config_s3_uri} /root/clearml.conf
              chmod 600 /root/clearml.conf

              sudo yum update -y
              sudo yum install -y git
              export PATH=$PATH:/usr/bin
              sudo yum install -y python3-pip
              sudo pip install --upgrade pip
              sudo pip install clearml-agent==${var.clearml_agent_update_version}

              sudo python3 -m clearml_agent daemon --force-current-version --foreground
              EOF

  tags = {
    Name = var.instance_name
  }
}
