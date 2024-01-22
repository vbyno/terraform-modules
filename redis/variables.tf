variable "name" {
  type = string
  description = "Name of the RDS instance"
}

variable "global_config" {
  description = "Global vpc config"
}

variable "redis_port" {
  type = string
  description = "Redis Port"
  default = "6379"
}

variable "node_type" {
  type = string
  default = "cache.t2.micro"
}

variable "parameter_group_name" {
  type = string
  default = "default.redis7"
}

variable "engine_version" {
  type = string
  default = "7.1"
}

variable "num_cache_nodes" {
  type = number
  default = 1
}
