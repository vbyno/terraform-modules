variable "name_prefix" {
  type = string
  description = "Name prefix of the EC2 instance and all related resources"
}

variable "subnet_id" {
  type = string
  description = "Subnet ID"
}

variable "launch_template_id" {
  type = string
}

variable "instance_type" {
  type = string
  default = "t3.micro"
}

variable "security_group_ids" {
  type = list(string)
  default = []
}

variable "my_public_ip" {
  type = string
  description = "Public IP address to open SSH connection from"
}

variable "vpc_id" {
  type = string
  description = "VPC TF ID"
}
