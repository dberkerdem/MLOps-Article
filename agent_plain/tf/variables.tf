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

variable "instance_name" {
  description = "The name to associate with the launched instance"
  type        = string
}

variable "security_group_id" {
  description = "The Security Group ID to associate with the EC2 instance"
  type        = string
}

variable "clearml_agent_update_version" {
  description = "Version of clearml-agent python package to be used"
  type        = string
}

variable "ami" {
  description = "The AMI to use for the instance"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile to be used for the instance"
  type        = string
}

variable "clearml_config_s3_uri" {
  description = "S3 URI to clearml.conf file"
  type        = string
}

variable "clearml_agent_queue" {
  description = "Queue that ClearML Agent to be registered to"
  type        = string
}

variable "clearml_conf_path" {
  description = "Path to clearml.conf file"
  type        = string
}

variable "clearml_config_bucket_name" {
  description = "Name of the s3 bucket that contains clearml.conf"
  type        = string
}

variable "ec2_role_name" {
  description = "Role name to be attached to EC2"
  type        = string
}