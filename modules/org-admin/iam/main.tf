
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
provider "aws" {
  region  = var.aws_billing_region
  profile = var.aws_profile
  alias = "aws_billing_region"
}
# --- AWS IAM User for Organization Admin ---
resource "aws_iam_user" "org_admin" {
  name = var.org_admin
  # IAM users are global, so no 'provider' argument is needed here;
  # it uses the default provider implicitly.
  tags = {
    user = var.org_admin
    role = "Organization Admin"
  }
}
resource "aws_iam_policy" "org_admin_policy" {
  name   = var.org_admin_policy
  policy = file("./modules/org-admin/iam/policies/88HoursOrgAdmin-FullAccess-policy.json") # Path to your policy file
}
# --- AWS IAM Policy for Organization Admin ---
resource "aws_iam_user_policy_attachment" "org_admin_attach" {
  user = "${var.org_admin}"
  #policy_arn = aws_iam_policy.org_admin_policy.arn
  policy_arn = aws_iam_policy.org_admin_policy.arn
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
