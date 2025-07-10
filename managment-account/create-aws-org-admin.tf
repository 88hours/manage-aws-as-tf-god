
variable "org_admin" {
  description = "The name of the IAM user"
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
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_login_profile" "org_admin_login" {
  user    = aws_iam_user.org_admin.name
  pgp_key = "keybase:<your-keybase-username>" # or omit for unencrypted password
}

resource "aws_iam_access_key" "org_admin_key" {
  user = aws_iam_user.org_admin.name
}
