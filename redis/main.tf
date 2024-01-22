resource "aws_elasticache_cluster" "redis" {
  cluster_id = "${var.name}-redis"
  engine                = "redis"
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = var.parameter_group_name
  engine_version       = var.engine_version
  port                 = var.redis_port
  subnet_group_name    = aws_elasticache_subnet_group.redis_sg.name
  security_group_ids   = [
    aws_security_group.redis_connection_security_group.id,
    aws_security_group.redis_access_security_group.id
  ]
}

resource "aws_elasticache_subnet_group" "redis_sg" {
  name       = "${var.name}-subnet-group"
  description = "Subnet group to connect to AWS elasticache cluster"
  subnet_ids = var.global_config.subnet_ids
}

resource "aws_security_group" "redis_connection_security_group" {
  name_prefix = "${var.name}-redis-connector-"
  description = "Redis Connection Security Group"
  vpc_id      = var.global_config.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name}_redis connection_security_group"
  }
}

resource "aws_security_group" "redis_access_security_group" {
  name_prefix = "${var.name}-redis-access-"
  description = "Redis Access Security Group"
  vpc_id      = var.global_config.vpc_id

  ingress {
    description = "Redis Access"
    from_port   = var.redis_port
    to_port     = var.redis_port
    protocol    = "tcp"
    security_groups = concat(
      [aws_security_group.redis_connection_security_group.id]
    )
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name}_redis access_security_group"
  }
}
