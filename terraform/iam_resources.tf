# Using existing iam resources

# Data source for the existing IAM role
data "aws_iam_role" "clock_ec2_ecr_role" {
  name = "clock_ec2_ecr_role"
}

# Data source for the existing IAM policy
data "aws_iam_policy" "clock_ecr_access_policy" {
  name = "clock_ecr_access_policy"
}

# Data source for the existing IAM instance profile
data "aws_iam_instance_profile" "clock_ec2_profile" {
  name = "clock_ec2_profile"
}

# Ensure the policy is attached to the role (this is idempotent)
resource "aws_iam_role_policy_attachment" "clock_ecr_policy_attach" {
  role       = data.aws_iam_role.clock_ec2_ecr_role.name
  policy_arn = data.aws_iam_policy.clock_ecr_access_policy.arn
}

# Output the ARNs of the existing resources for reference
output "role_arn" {
  value = data.aws_iam_role.clock_ec2_ecr_role.arn
}

output "policy_arn" {
  value = data.aws_iam_policy.clock_ecr_access_policy.arn
}

output "instance_profile_arn" {
  value = data.aws_iam_instance_profile.clock_ec2_profile.arn
}