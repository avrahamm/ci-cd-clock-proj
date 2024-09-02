variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "clock-prod"
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-central-1"
}