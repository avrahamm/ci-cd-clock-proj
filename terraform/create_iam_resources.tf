# # # To run once to create resources.
# # # cd terraform
# # # terraform init
# # # terraform plan -target=aws_iam_role.clock_ec2_ecr_role -target=aws_iam_policy.clock_ecr_access_policy -target=aws_iam_role_policy_attachment.clock_ecr_policy_attach -target=aws_iam_instance_profile.clock_ec2_profile
# # # terraform apply -target=aws_iam_role.clock_ec2_ecr_role -target=aws_iam_policy.clock_ecr_access_policy -target=aws_iam_role_policy_attachment.clock_ecr_policy_attach -target=aws_iam_instance_profile.clock_ec2_profile
# #
# #
# # First, plan the changes
# #  terraform plan \
# #  -target=aws_iam_role.clock_ec2_ecr_role \
# #  -target=aws_iam_policy.clock_ecr_access_policy \
# #  -target=aws_iam_role_policy_attachment.clock_ecr_policy_attach \
# #  -target=aws_iam_instance_profile.clock_ec2_profile \
# #  -target=aws_iam_policy.clock_ecr_public_auth_token_policy \
# #  -target=aws_iam_role_policy_attachment.clock_ecr_public_auth_token_policy_attach
# #
# # # If the plan looks good, apply the changes
# #  terraform apply \
# #  -target=aws_iam_role.clock_ec2_ecr_role \
# #  -target=aws_iam_policy.clock_ecr_access_policy \
# #  -target=aws_iam_role_policy_attachment.clock_ecr_policy_attach \
# #  -target=aws_iam_instance_profile.clock_ec2_profile \
# #  -target=aws_iam_policy.clock_ecr_public_auth_token_policy \
# #  -target=aws_iam_role_policy_attachment.clock_ecr_public_auth_token_policy_attach
#
#
# # IAM Role
# resource "aws_iam_role" "clock_ec2_ecr_role" {
#   name = "clock_ec2_ecr_role"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       }
#     ]
#   })
# }
#
# # IAM Policy
# resource "aws_iam_policy" "clock_ecr_access_policy" {
#   name        = "clock_ecr_access_policy"
#   path        = "/"
#   description = "IAM policy for comprehensive ECR access"
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "ecr:GetAuthorizationToken",
#           "ecr:BatchCheckLayerAvailability",
#           "ecr:GetDownloadUrlForLayer",
#           "ecr:GetRepositoryPolicy",
#           "ecr:DescribeRepositories",
#           "ecr:ListImages",
#           "ecr:DescribeImages",
#           "ecr:BatchGetImage",
#           "ecr:InitiateLayerUpload",
#           "ecr:UploadLayerPart",
#           "ecr:CompleteLayerUpload",
#           "ecr:PutImage",
#           "ecr-public:GetAuthorizationToken",
#           "ecr-public:BatchCheckLayerAvailability",
#           "ecr-public:GetRepositoryPolicy",
#           "ecr-public:DescribeRepositories",
#           "ecr-public:DescribeImages",
#           "ecr-public:DescribeRegistries",
#           "ecr-public:InitiateLayerUpload",
#           "ecr-public:UploadLayerPart",
#           "ecr-public:CompleteLayerUpload",
#           "ecr-public:PutImage",
#           "sts:GetServiceBearerToken",
#           "sts:AssumeRole"
#         ]
#         Resource = "*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ]
#         Resource = "arn:aws:logs:*:*:*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "ssm:GetParameter",
#           "ssm:GetParameters",
#           "ssm:GetParametersByPath"
#         ]
#         Resource = "arn:aws:ssm:*:*:parameter/*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "kms:Decrypt"
#         ]
#         Resource = "*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "iam:PassRole"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }
#
# # Attach the policy to the role
# resource "aws_iam_role_policy_attachment" "clock_ecr_policy_attach" {
#   role       = aws_iam_role.clock_ec2_ecr_role.name
#   policy_arn = aws_iam_policy.clock_ecr_access_policy.arn
# }
#
# # Create an instance profile
# resource "aws_iam_instance_profile" "clock_ec2_profile" {
#   name = "clock_ec2_profile"
#   role = aws_iam_role.clock_ec2_ecr_role.name
# }
#
# resource "aws_iam_policy" "clock_ecr_public_auth_token_policy" {
#   name        = "clock_ecr_public_auth_token_policy"
#   path        = "/"
#   description = "IAM policy for ECR public GetAuthorizationToken"
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "ecr-public:GetAuthorizationToken",
#           "sts:GetServiceBearerToken"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }
#
# resource "aws_iam_role_policy_attachment" "clock_ecr_public_auth_token_policy_attach" {
#   role       = aws_iam_role.clock_ec2_ecr_role.name
#   policy_arn = aws_iam_policy.clock_ecr_public_auth_token_policy.arn
# }
#
# # Outputs
# output "role_arn" {
#   value = aws_iam_role.clock_ec2_ecr_role.arn
# }
#
# output "policy_arn" {
#   value = aws_iam_policy.clock_ecr_access_policy.arn
# }
#
# output "clock_ecr_public_auth_token_policy_arn" {
#   value = aws_iam_policy.clock_ecr_public_auth_token_policy.arn
# }
#
# output "instance_profile_arn" {
#   value = aws_iam_instance_profile.clock_ec2_profile.arn
# }
#
