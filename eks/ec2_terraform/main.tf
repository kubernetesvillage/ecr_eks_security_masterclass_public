# Provider Configuration
provider "aws" {
  region = var.region
}

# Get the Default VPC
data "aws_vpc" "default" {
  default = true
}

# Get the Default Subnets in the Default VPC
data "aws_subnets" "default_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Get the Default Security Group in the Default VPC
data "aws_security_group" "default" {
  filter {
    name   = "group-name"
    values = ["default"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Add Ingress Rule to the Default Security Group
resource "aws_security_group_rule" "allow_8080_in_default_sg" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.default.id
}

# Get the Latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Create the EC2 Instance
resource "aws_instance" "peachycloudsecurity_instance" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [data.aws_security_group.default.id]
  subnet_id                   = element(data.aws_subnets.default_vpc_subnets.ids, 0)
  tags = {
    Name = "peachycloudsecurity_instance"
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo amazon-linux-extras install docker -y
                sudo service docker start
                sudo usermod -a -G docker ec2-user
                sudo docker run -d -p 8080:8080 -p 50000:50000 -p 5005:5005 gurubaba/jenkins:latest
                EOF

  provisioner "local-exec" {
    command = "bash check_instance_status.sh ${self.id} ${var.region}"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2  # Hop limit added here
    instance_metadata_tags      = "enabled"
  }
}
