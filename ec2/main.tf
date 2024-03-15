resource "aws_instance" "aws_server" {
  instance_type = var.instance_type

  network_interface {
    network_interface_id = aws_network_interface.ongoing_network_interface.id
    device_index = 0
  }

  launch_template {
    id      = var.launch_template_id
    version = var.launch_template_version
  }

  lifecycle {
    ignore_changes = [tags, user_data]
  }

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp2"
  }
}

resource "aws_network_interface" "ongoing_network_interface" {
  subnet_id       = var.subnet_id
  security_groups = concat(
    [aws_security_group.ec2_security_group.id],
    var.security_group_ids
  )
}

resource "aws_security_group" "ec2_security_group" {
  name_prefix = "${var.name_prefix}_sg"
  description = "Allow SSH from the current machine public IP and HTTP for everyone"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    description = "SSH from Local Machine"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_public_ip}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.name_prefix}_security_group"
  }
}
