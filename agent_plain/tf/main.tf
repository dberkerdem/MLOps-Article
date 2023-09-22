terraform {
  backend "local" {
    path = "default.tfstate"
  }
}

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "config_bucket" {
  bucket = "clearml-agent-config-bucket"
  acl    = "private"
}

resource "aws_s3_object" "clearml_config" {
  bucket = aws_s3_bucket.config_bucket.bucket
  key    = "clearml.conf"
  source = "../clearml.conf"
  etag   = filemd5("../clearml.conf")
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

              aws s3 cp s3://${aws_s3_bucket.config_bucket.bucket}/clearml.conf /root/clearml.conf
              chmod 600 /root/clearml.conf

              sudo yum update -y
              sudo yum install -y
              sudo yum install -y python3-pip
              sudo pip install --upgrade pip
              sudo pip install clearml-agent==${var.clearml_agent_update_version}

              sudo python3 -m clearml_agent daemon --force-current-version --foreground
              EOF

  tags = {
    Name = var.instance_name
  }
}
