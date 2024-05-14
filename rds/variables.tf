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

variable "identifier" {
  description = "The identifier to use for the database instance, if set"
  type        = string
}

variable "instance_class" {
  type = string
  default = "db.t4g.micro"
}

variable "allow_major_version_upgrade" {
  type = bool
  default = true
}
