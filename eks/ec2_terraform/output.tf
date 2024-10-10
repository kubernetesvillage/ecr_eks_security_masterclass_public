output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.peachycloudsecurity_instance.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.peachycloudsecurity_instance.public_dns
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.peachycloudsecurity_instance.arn
}
