resource "aws_organizations_organization" "org" {
  feature_set = "ALL"
    enabled_policy_types = ["SERVICE_CONTROL_POLICY"]
}

# Create the Developer OU under the existing root
resource "aws_organizations_organizational_unit" "developer_ou" {
  name      = var.ou_name
  parent_id = aws_organizations_organization.org.roots[0].id
}

# Create a Service Control Policy to restrict root user
resource "aws_organizations_policy" "restrict_root_scp" {
  name        = "RestrictRootUserActions"
  description = "Restricts root user from performing write actions"
  type        = "SERVICE_CONTROL_POLICY"

  content = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyRootAllExceptReadOnly",
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:PrincipalArn": "arn:aws:iam::*:root"
        }
      }
    }
  ]
}
POLICY
}

# Attach the SCP to the Developer OU (or change to root/account if needed)
resource "aws_organizations_policy_attachment" "attach_restrict_root" {
  policy_id = aws_organizations_policy.restrict_root_scp.id
  target_id = aws_organizations_organizational_unit.developer_ou.id
}
