locals {
  db_port = 5432
}

resource "random_password" "password" {
  length  = 16
  special = false
  upper = true
}

resource "aws_db_subnet_group" "default" {
  name_prefix = "${var.name}-subnetgroup-"
  subnet_ids = var.global_config.subnet_ids

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "app_db" {
  allocated_storage    = 5
  max_allocated_storage = 0
  engine               = "postgres"
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  storage_type         = "standard"
  db_name              = var.name
  identifier           = var.identifier
  port                 = local.db_port
  username             = "postgres_user"
  password             = random_password.password.result
  skip_final_snapshot  = true
  publicly_accessible  = false
  deletion_protection  = var.deletion_protection
  allow_major_version_upgrade = var.allow_major_version_upgrade
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.security_group_db.id]
}

resource "aws_security_group" "connection_security_group" {
  name_prefix = "${var.name}-db-connector-"
  description = "Connection Security Group"
  vpc_id      = var.global_config.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name}_connection_security_group"
  }
}

resource "aws_security_group" "ip_access_security_group" {
  for_each = var.my_public_ip == "" ? toset([]) : toset(["1"])

  name_prefix = "${var.name}-db-ip-"
  description = "IP-based access Security Group"
  vpc_id      = var.global_config.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    description = "HTTP access from a specific IP address"
    from_port   = 0
    to_port     = local.db_port
    protocol    = "tcp"
    cidr_blocks = ["${var.my_public_ip}/32"]
  }

  tags = {
    Name = "${var.name}_ip_security_group"
  }
}

resource "aws_security_group" "security_group_db" {
  name_prefix = "${var.name}-sg-db-"
  description = "Allows DB connection to security group"
  vpc_id      = var.global_config.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    description = "DB Connection"
    from_port   = local.db_port
    to_port     = local.db_port
    protocol    = "tcp"
    security_groups = concat(
      [aws_security_group.connection_security_group.id],
      var.assigned_security_groups,
      [for sg in aws_security_group.ip_access_security_group: sg.id]
    )
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.name}_db_security_group"
  }
}
