
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
}

# --- AWS IAM Policy for Organization Admin ---
resource "aws_iam_user_policy" "org_admin_policy" {
  name = "${var.org_admin}-FullAccess"
  user = aws_iam_user.org_admin.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "organizations:*",
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "iam:CreateAccessKey",
          "iam:ListAccessKeys",
          "iam:DeleteAccessKey",
          "iam:GetLoginProfile",
          "iam:CreateLoginProfile",
          "iam:UpdateLoginProfile",
          "iam:DeleteLoginProfile",
          "iam:ListUsers"
        ],
        Resource = "arn:aws:iam::*:user/${aws_iam_user.org_admin.name}"
      },
      {
        Effect = "Allow",
        Action = [
          "sts:AssumeRole"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = "ec2:DescribeRegions",
        Resource = "*"
      },
      # --- ADD THESE SNS PERMISSIONS ---
      {
        Effect = "Allow",
        Action = [
          "sns:CreateTopic",
          "sns:Publish",
          "sns:Subscribe",
          "sns:Receive",
          "sns:ListTopics",
          "sns:ListSubscriptions",
          "sns:GetTopicAttributes",
          "sns:SetTopicAttributes",
          "sns:DeleteTopic",
          "sns:Unsubscribe",
          "sns:TagResource",     
          "sns:UntagResource",
          "sns:ListTagsForResource",
          "sns:ConfirmSubscription",
          "sns:ListSubscriptionsByTopic",
          "sns:GetSubscriptionAttributes",
          "sns:SetSubscriptionAttributes",
          "sns:DeleteSubscription",
          "sns:ReceiveMessage",
          "sns:ListSubscriptionsByTopic",
        ],
        Resource = "*" # Allows SNS actions on all topics. You can restrict to specific ARNs if needed.
      },
      # --- ADD THESE CLOUDWATCH PERMISSIONS (for alarms) ---
      {
        Effect = "Allow",
        Action = [
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:DeleteAlarms",
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics",
          "cloudwatch:EnableAlarmActions",
          "cloudwatch:DisableAlarmActions",
          "cloudwatch:SetAlarmState",
          "cloudwatch:DescribeAlarmHistory",
          "cloudwatch:GetMetricStatistics", # Specifically for billing metrics
          "cloudwatch:PutMetricData", # If you need to send custom metrics
          "cloudwatch:ListTagsForResource",
          "cloudwatch:TagResource",
          "cloudwatch:UntagResource",

        ],
        Resource = "*" # CloudWatch actions are often *
      },
      # --- ADD THESE BILLING PERMISSIONS (for estimated charges metric) ---
      {
        Effect = "Allow",
        Action = [
          "ce:GetCostAndUsage",             # For more detailed billing info (AWS Budgets might use this)
          "aws-portal:ViewBilling",
          "aws-portal:ViewUsage",
          "aws-portal:ViewAccount",
          "aws-portal:ModifyBilling"        # If they need to change billing preferences
        ],
        Resource = "*"
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
