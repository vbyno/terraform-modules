variable "name_prefix" {
  type = string
  description = "Name prefix of the EC2 instance and all related resources"
}

variable "ssh_local_pub_key" {
  type = string
  description = "Public SSH key to connect to EC2 instance"
}

variable "app_version" {
  type = number
  description = "application version (to recreate ec2 instances)"
  default = 1
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}
