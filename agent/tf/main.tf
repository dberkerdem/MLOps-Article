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
              
              sudo yum update -y
              sudo yum install docker -y
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              sudo chkconfig docker on
              sudo yum install -y git
              
              git clone var.repo_url
              cd MLOps-Article
              echo '${local.env_content}' > ./agent/.env

              sudo chmod +x scipts/*
              sh scripts/build_agent_image.sh
              sh scripts/run_workers.sh --num-workers 1
              EOF

  tags = {
    Name = var.instance_name
  }
}