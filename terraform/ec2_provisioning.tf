data "aws_iam_instance_profile" "existing_profile" {
  name = "ec2_profile"
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
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t2.micro"
  key_name               = "clock1"
  iam_instance_profile   = data.aws_iam_instance_profile.existing_profile.name
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
    # Install AWS CLI v2
    sudo yum install -y unzip
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip
    # Install the Amazon ECR Credential Helper
    sudo yum install -y amazon-ecr-credential-helper
    # Create .docker directory
    mkdir -p /home/ec2-user/.docker
    chown -R ec2-user:ec2-user /home/ec2-user/.docker
    # Signal that the instance is ready
    touch /tmp/instance_ready
    chown ec2-user:ec2-user /tmp/instance_ready
    # Reboot to ensure all changes take effect
    sudo reboot
  EOF
  )

  tags = {
    Name = var.instance_name
  }
}