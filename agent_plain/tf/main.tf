terraform {
  backend "local" {
    path = "default.tfstate"
  }
}

provider "aws" {
  region = var.region
}

locals {
  userdata = templatefile("userdata.sh", {
    clearml_config_s3_uri = var.clearml_config_s3_uri,
    clearml_conf_path = var.clearml_conf_path,
    instance_name = var.instance_name,
    clearml_agent_update_version = var.clearml_agent_update_version,
    clearml_agent_queue = var.clearml_agent_queue
  })
}

resource "aws_instance" "clearml_agent" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [var.security_group_id]
  user_data = local.userdata
  iam_instance_profile = aws_iam_instance_profile.this.name

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_type = "gp3"
    volume_size = 10
  }

  tags = {
    Name = var.instance_name
  }
}
