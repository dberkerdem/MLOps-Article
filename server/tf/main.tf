terraform {
  backend "local" {}
}

provider "aws" {
  region = var.region
}

locals {
  userdata = templatefile("userdata.sh", {
    ssm_cloudwatch_config = aws_ssm_parameter.cw_agent.name,
    env_variables_content = data.local_file.env_variables.content
  })
}

data "local_file" "env_variables" {
  filename = "${path.module}/.env.sh"
}

resource "aws_security_group" "clearml_server_sg" {
  name        = "clearml_server_sg"
  description = "Security group for clearml server"

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows SSH from any IP. Consider restricting this for security.
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8008
    to_port     = 8008
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # This represents all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "clearml_server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name

  vpc_security_group_ids = [aws_security_group.clearml_server_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.this.name
  user_data              = local.userdata
  tags                   = {Name = "clearml_server"}
}

resource "aws_ssm_parameter" "cw_agent" {
  description = "Cloudwatch agent config to configure custom log for ClearML Server"
  name        = "/cloudwatch-agent/config"
  type        = "String"
  value       = file("cw-agent-config.json")
}

output "private_ipv4" {
  description = "The private IPv4 address of the ClearML server."
  value       = aws_instance.clearml_server.private_ip
}

output "public_ipv4_dns" {
  description = "The public IPv4 DNS of the ClearML server."
  value       = aws_instance.clearml_server.public_dns
}

output "instance_id" {
  description = "The instance ID of the ClearML server."
  value       = aws_instance.clearml_server.id
}
