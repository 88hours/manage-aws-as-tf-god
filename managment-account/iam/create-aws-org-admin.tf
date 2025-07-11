variable "aws_profile" {
  description = "The AWS credentials profile name"
  type        = string
}
provider "aws" {
  region  = "ap-southeast-2"
  profile = var.aws_profile
}
variable "org_admin" {
  description = "The name of the organisation admin"
  type        = string
}
resource "aws_iam_user" "org_admin" {
  name = var.org_admin
}

resource "aws_iam_user_policy" "org_admin_policy" {
  name = "OrgAdminFullAccess"
  user = aws_iam_user.org_admin.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "organizations:*",
        Resource = "arn:aws:iam::*:user/${aws_iam_user.org_admin.name}"
      },
      {
        Effect = "Allow",
        Action = [
          "iam:CreateAccessKey",
          "iam:ListAccessKeys",
          "iam:DeleteAccessKey"
        ],
        Resource = "arn:aws:iam::*:user/${aws_iam_user.org_admin.name}"
      }
    ]
  })
}


data "aws_iam_access_keys" "org_admin" {
  user = aws_iam_user.org_admin.name
}

resource "aws_iam_user_login_profile" "org_admin_login" {
  user = aws_iam_user.org_admin.name
  #pgp_key = "keybase:<your-keybase-username>" # or omit for unencrypted password
  password_reset_required = true
  lifecycle {
    #precondition {
    #  condition     = length(data.aws_iam_access_keys.org_admin.access_keys) < 2
    #  error_message = "User already has 2 access keys. Cannot create more."
    #}
  }
}

resource "aws_iam_access_key" "org_admin_key" {
  user = aws_iam_user.org_admin.name
}

output "org_admin" {
  value = var.org_admin
}