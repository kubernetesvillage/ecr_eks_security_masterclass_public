variable "region" {
  description = "The AWS region to deploy resources."
  default     = "us-west-2"
}

variable "ec2_ami" {
  description = "The EC2 AMI ID to use for the instance."
  default     = "ami-0323ead22d6752894" # Amazon Linux 2 AMI
}

variable "instance_type" {
  description = "The type of EC2 instance to use."
  default     = "t3.micro"
}
