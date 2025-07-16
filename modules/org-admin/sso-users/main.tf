
data "aws_ssoadmin_instances" "this" {}

resource "aws_identitystore_user" "sso_users" {
  for_each = { for user in var.sso_users : user.user_name => user }

  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]
  user_name         = each.value.user_name
  display_name = each.value.display_name
  name {
    given_name  = each.value.display_name
    family_name  = each.value.display_name
    formatted    = each.value.display_name
  }
  emails {
    value   = each.value.email
    primary = true
    type    = "work"
  }
}


resource "aws_ssoadmin_permission_set" "admin_access" {
  name             = var.permission_set_name
  description      = var.permission_set_description
  instance_arn     = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  session_duration = "PT8H"
}
resource "aws_ssoadmin_permission_set_inline_policy" "admin_policy" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin_access.arn

  inline_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "*",
        Resource = "*"
      }
    ]
  })
}

resource "aws_ssoadmin_account_assignment" "assign_users" {
  for_each = aws_identitystore_user.sso_users

  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin_access.arn
  principal_id       = each.value.user_id
  principal_type     = "USER"
  target_id          = var.target_account_id
  target_type        = "AWS_ACCOUNT"
}