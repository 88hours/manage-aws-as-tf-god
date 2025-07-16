#!/bin/bash

# Set this before running
ACCOUNT_ID="684273075367"
REGION="us-east-1"

echo "Starting Terraform imports for pre-existing AWS resources..."

# Import CloudWatch alarm
terraform import module.billing_alarm_setup.aws_cloudwatch_metric_alarm.estimated_charges_alarm "org-billing-alert-1usd"

# Import SNS topic
terraform import module.billing_alarm_setup.aws_sns_topic.billing_alert_topic "arn:aws:sns:${REGION}:${ACCOUNT_ID}:org-billing-alert-topic"

# Get subscription ARN dynamically (assumes only one matching)
SUB_ARN=$(aws sns list-subscriptions-by-topic \
  --topic-arn arn:aws:sns:${REGION}:${ACCOUNT_ID}:org-billing-alert-topic \
  --query "Subscriptions[?Endpoint=='itsnomihere@gmail.com'].SubscriptionArn" \
  --output text)

if [ -z "$SUB_ARN" ]; then
  echo "❌ SNS subscription for itsnomihere@gmail.com not found."
else
  terraform import module.billing_alarm_setup.aws_sns_topic_subscription.billing_alert_email_subscriptions[\"itsnomihere@gmail.com\"] "$SUB_ARN"
fi

# Import IAM access key (replace with real access key ID)
ACCESS_KEY_ID=$(aws iam list-access-keys --user-name 88HoursOrgAdmin --query 'AccessKeyMetadata[0].AccessKeyId' --output text)

if [ -z "$ACCESS_KEY_ID" ]; then
  echo "❌ No access key found for IAM user 88HoursOrgAdmin."
else
  terraform import module.delegate_admin.aws_iam_access_key.org_admin_key "88HoursOrgAdmin/$ACCESS_KEY_ID"
fi

# Import IAM user login profile
terraform import module.delegate_admin.aws_iam_user_login_profile.org_admin_login "88HoursOrgAdmin"

echo "✅ All available resources imported."
