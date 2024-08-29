variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "clock-test"
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-central-1"
}