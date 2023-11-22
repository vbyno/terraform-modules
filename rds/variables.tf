variable "name" {
  type = string
  description = "Name of the RDS instance"
}

variable "global_config" {
  description = "Global vpc config"
}

variable "assigned_security_groups" {
  type = list(string)
  default = []
}

variable "engine_version" {
    type = string
    default = "15.3"
}

variable "my_public_ip" {
  type = string
  default = ""
}
