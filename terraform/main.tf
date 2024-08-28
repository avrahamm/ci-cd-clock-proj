# Define variables for instance names
variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "clock-test"  # Default value if not provided
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default = "eu-central-1"
}

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_security_group" "web_service_sg" {
  name = "WebServiceSG"
}

resource "aws_instance" "clock_instance" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"
  key_name      = "clock1"

  vpc_security_group_ids = [data.aws_security_group.web_service_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -ex
    # Update the system
    sudo yum update -y
    # Install and configure Docker
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user
    # Install Git
    sudo yum install -y git
    # Create Docker admin directory and set appropriate ownership
    mkdir -p /home/ec2-user/.docker
    chown -R ec2-user:ec2-user /home/ec2-user/.docker
    # Reboot to ensure all changes take effect
    sudo reboot
  EOF
  )

  tags = {
    Name = var.instance_name
  }
}

output "instance_public_ip" {
  value = aws_instance.clock_instance.public_ip
}

output "instance_id" {
  value = aws_instance.clock_instance.id
}

output "instance_state" {
  description = "The state of the EC2 instance"
  value       = aws_instance.clock_instance.instance_state
}
