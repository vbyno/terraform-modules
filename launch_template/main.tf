resource "aws_key_pair" "aws_key" {
  key_name_prefix = "my_aws_key"
  public_key      = trimspace(var.ssh_local_pub_key)
}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

locals {
  user_data = <<-EOT
#!/bin/bash
# DOCKER INSTALLATION
yum update -y
amazon-linux-extras install docker -y
service docker start
usermod -a -G docker ec2-user
curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Allocate space for a 1GB swap file
sudo dd if=/dev/zero of=/swapfile bs=1M count=2048
# Secure the swap file
sudo chmod 600 /swapfile
# Set up a Linux swap area
sudo mkswap /swapfile
# Make the swap file available for immediate use
sudo swapon /swapfile
# Ensure the swap file persists on reboot
sudo echo '/swapfile swap swap defaults 0 0' >> /etc/fstab
EOT
}

resource "aws_launch_template" "app_template" {
  name_prefix   = "${var.name_prefix}-"
  image_id      = coalesce(var.launch_template_image_id, data.aws_ami.latest_amazon_linux.id)
  instance_type = var.instance_type
  key_name      = aws_key_pair.aws_key.key_name
  default_version = var.app_version
  user_data = base64encode(local.user_data)

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.name_prefix}-instance"
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.name_prefix}-ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.name_prefix}-ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy_attachment" "ec2_policy_attachment" {
  name       = "ec2_policy_attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  roles      = [aws_iam_role.ec2_role.name]
}
