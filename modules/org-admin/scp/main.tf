resource "aws_organizations_organization" "org" {
  feature_set = "ALL"
    enabled_policy_types = ["SERVICE_CONTROL_POLICY"]
     # Keep SSO service enabled for AWS Org
  aws_service_access_principals = [
    "sso.amazonaws.com"
  ]
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

resource "aws_organizations_policy" "developer_scp" {
  name        = "DeveloperAccessPolicy"
  description = "Restrict developers to safe actions and specific regions"
  type        = "SERVICE_CONTROL_POLICY"

  content = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyDestructiveIAM",
      "Effect": "Deny",
      "Action": [
        "iam:DeleteUser",
        "iam:DeleteRole",
        "iam:DeletePolicy",
        "iam:DeleteGroup",
        "iam:DetachRolePolicy",
        "iam:DetachUserPolicy"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyDisablingLogging",
      "Effect": "Deny",
      "Action": [
        "cloudtrail:DeleteTrail",
        "cloudtrail:StopLogging",
        "logs:DeleteLogGroup",
        "logs:DeleteLogStream"
      ],
      "Resource": "*"
    },
    {
      "Sid": "RestrictRegions",
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestedRegion": [
            "us-east-1",
            "ap-southeast-2"
          ]
        }
      }
    }
  ]
}
POLICY
}

resource "aws_organizations_policy_attachment" "attach_developer_scp" {
  policy_id = aws_organizations_policy.developer_scp.id
  target_id = aws_organizations_organizational_unit.developer_ou.id
}
