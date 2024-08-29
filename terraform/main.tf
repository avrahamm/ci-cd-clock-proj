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

# Create IAM role for EC2
resource "aws_iam_role" "ec2_ecr_role" {
  name = "ec2_ecr_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Create IAM policy for ECR access
resource "aws_iam_policy" "ecr_access_policy" {
  name        = "ecr_access_policy"
  path        = "/"
  description = "IAM policy for ECR access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr-public:GetAuthorizationToken",
          "ecr-public:BatchCheckLayerAvailability",
          "ecr-public:GetRepositoryPolicy",
          "ecr-public:DescribeRepositories",
          "ecr-public:DescribeImages",
          "ecr-public:InitiateLayerUpload",
          "ecr-public:UploadLayerPart",
          "ecr-public:CompleteLayerUpload",
          "ecr-public:PutImage",
          "sts:GetServiceBearerToken"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "ecr_policy_attach" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}

# Create an instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_ecr_role.name
}

resource "aws_instance" "clock_instance" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"
  key_name      = "clock1"

  vpc_security_group_ids = [data.aws_security_group.web_service_sg.id]

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

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

    # Configure Docker to use the ECR Credential Helper
    mkdir -p /home/ec2-user/.docker

    # Create Docker admin directory and set appropriate ownership
    mkdir -p /home/ec2-user/.docker
    chown -R ec2-user:ec2-user /home/ec2-user/.docker
    # Signal that the instance is ready and set appropriate ownership
    touch /tmp/instance_ready
    chown ec2-user:ec2-user /tmp/instance_ready
  EOF
  )

  tags = {
    Name = var.instance_name
  }
}

# Previous parts of the script remain unchanged

data "aws_instance" "clock_instance_status" {
  instance_id = aws_instance.clock_instance.id

  depends_on = [aws_instance.clock_instance]
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

output "instance_status" {
  description = "Detailed status of the EC2 instance"
  value = {
    state                 = data.aws_instance.clock_instance_status.instance_state
    availability_zone     = data.aws_instance.clock_instance_status.availability_zone
    public_ip             = data.aws_instance.clock_instance_status.public_ip
    private_ip            = data.aws_instance.clock_instance_status.private_ip
  }
}