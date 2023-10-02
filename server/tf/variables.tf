variable "region" {
  description = "The AWS region where resources will be created"
  type        = string
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
}

variable "ami" {
  description = "The AMI to use for the instance"
  type        = string
}

variable "key_name" {
  description = "The key name to be used for the instance"
  type        = string
}
