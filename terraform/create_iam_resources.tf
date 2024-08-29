# # To run once to create resources.
# # cd terraform
# # terraform init
# # terraform plan -target=aws_iam_role.clock_ec2_ecr_role -target=aws_iam_policy.clock_ecr_access_policy -target=aws_iam_role_policy_attachment.clock_ecr_policy_attach -target=aws_iam_instance_profile.clock_ec2_profile
# # terraform apply -target=aws_iam_role.clock_ec2_ecr_role -target=aws_iam_policy.clock_ecr_access_policy -target=aws_iam_role_policy_attachment.clock_ecr_policy_attach -target=aws_iam_instance_profile.clock_ec2_profile
#
#
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
# resource "aws_iam_policy" "clock_ecr_access_policy" {
#   name        = "clock_ecr_access_policy"
#   path        = "/"
#   description = "IAM policy for ECR access"
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "ecr-public:GetAuthorizationToken",
#           "ecr-public:BatchCheckLayerAvailability",
#           "ecr-public:GetRepositoryPolicy",
#           "ecr-public:DescribeRepositories",
#           "ecr-public:DescribeImages",
#           "ecr-public:InitiateLayerUpload",
#           "ecr-public:UploadLayerPart",
#           "ecr-public:CompleteLayerUpload",
#           "ecr-public:PutImage",
#           "sts:GetServiceBearerToken"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }
#
# resource "aws_iam_role_policy_attachment" "clock_ecr_policy_attach" {
#   role       = aws_iam_role.clock_ec2_ecr_role.name
#   policy_arn = aws_iam_policy.clock_ecr_access_policy.arn
# }
#
# resource "aws_iam_instance_profile" "clock_ec2_profile" {
#   name = "clock_ec2_profile"
#   role = aws_iam_role.clock_ec2_ecr_role.name
# }