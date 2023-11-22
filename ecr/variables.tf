variable "name" {
  type        = string
  description = "A name of the ecr"
  default     = "psm-ecr"
}

variable "aws_ecr_read_iam_identifiers" {
  type = string
  description = "list of IAM identifiers to share repositories with. Separated with comma"
  default = ""
}
