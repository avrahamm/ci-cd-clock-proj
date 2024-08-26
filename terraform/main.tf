# Define variables for instance names
variable "instance_names" {
  description = "Names for the EC2 instances"
  type        = list(string)
  default     = ["clock-test", "clock-prod"]
}

provider "aws" {
  region = "eu-central-1"
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

resource "aws_instance" "clock_instances" {
  count         = length(var.instance_names)
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
    # Create Docker login script
    mkdir -p /home/ec2-user/.docker
    cat << EOT > /home/ec2-user/.docker/docker_login.sh
    #!/bin/bash
    set -ex
    echo "$${DOCKER_PASSWORD}" | docker login -u "$${DOCKER_USERNAME}" --password-stdin
    EOT
    chmod +x /home/ec2-user/.docker/docker_login.sh
    # Create Docker cleanup script
    cat << EOT > /home/ec2-user/.docker/docker_cleanup.sh
    #!/bin/bash
    docker system prune -af
    docker volume prune -f
    EOT
    chmod +x /home/ec2-user/.docker/docker_cleanup.sh
    # Set appropriate ownership
    chown -R ec2-user:ec2-user /home/ec2-user/.docker
    # Reboot to ensure all changes take effect
    sudo reboot
  EOF
  )

  tags = {
    Name = var.instance_names[count.index]
  }
}

output "instance_public_ips" {
  value = {
    for i, instance in aws_instance.clock_instances : var.instance_names[i] => instance.public_ip
  }
}