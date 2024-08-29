# Using existing iam resources

# Data source for the existing IAM role
data "aws_iam_role" "ec2_ecr_role" {
  name = "ec2_ecr_role"
}

# Data source for the existing IAM policy
data "aws_iam_policy" "ecr_access_policy" {
  name = "ecr_access_policy"
}

# Data source for the existing IAM instance profile
data "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
}

# Ensure the policy is attached to the role (this is idempotent)
resource "aws_iam_role_policy_attachment" "ecr_policy_attach" {
  role       = data.aws_iam_role.ec2_ecr_role.name
  policy_arn = data.aws_iam_policy.ecr_access_policy.arn
}

# Output the ARNs of the existing resources for reference
output "role_arn" {
  value = data.aws_iam_role.ec2_ecr_role.arn
}

output "policy_arn" {
  value = data.aws_iam_policy.ecr_access_policy.arn
}

output "instance_profile_arn" {
  value = data.aws_iam_instance_profile.ec2_profile.arn
}