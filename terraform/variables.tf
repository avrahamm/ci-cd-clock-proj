# Define variables for instance names
variable "instance_names" {
  description = "Names for the EC2 instances"
  type        = list(string)
  default     = ["clock-test", "clock-prod"]
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-central-1"
}