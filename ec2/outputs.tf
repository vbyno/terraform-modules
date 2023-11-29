output "public_ip" {
  value = aws_instance.aws_server.public_ip
}

output "ec2_instance_id" {
  value = aws_instance.aws_server.id
}

output "public_dns" {
  value = aws_instance.aws_server.public_dns
}
