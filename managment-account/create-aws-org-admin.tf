
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

resource "aws_iam_user_login_profile" "org_admin_login" {
  user    = aws_iam_user.org_admin.name
  #pgp_key = "keybase:<your-keybase-username>" # or omit for unencrypted password
  password_reset_required = true
}

resource "aws_iam_access_key" "org_admin_key" {
  user = aws_iam_user.org_admin.name
}

output "org_admin" {
  value = var.org_admin
}