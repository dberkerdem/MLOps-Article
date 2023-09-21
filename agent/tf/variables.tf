variable "region" {
  description = "The AWS region where resources will be created"
  type        = string
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
}

variable "key_name" {
  description = "The key name to be used for the instance"
  type        = string
}

variable "security_group_name" {
  description = "The name of the security group to associate with the EC2 instance"
  type        = string
}

variable "repo_url" {
  description = "The URL of the repository to be cloned on the instance"
  type        = string
}

variable "instance_name" {
  description = "The name to associate with the launched instance"
  type        = string
}

variable "security_group_id" {
  description = "The Security Group ID to associate with the EC2 instance"
  type        = string
}

variable "docker_image" {
  description = "Name of the docker image to be used as agent"
  type        = string
}
