resource "aws_organizations_policy" "restrict_root_scp" {
  name        = "RestrictRootUserActions"
  description = "Restricts root user from any actions except read-only"
  type        = "SERVICE_CONTROL_POLICY"

  content = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyRootUserActions",
      "Effect": "Deny",
      "Principal": {
        "AWS": "arn:aws:iam::${var.target_account_id}:root"
      },
      "Action": "*",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_organizations_policy_attachment" "attach_restrict_root" {
  policy_id = aws_organizations_policy.restrict_root_scp.id
  target_id = var.target_account_id
  # Or use member account id for target_id to attach to a single account
}
