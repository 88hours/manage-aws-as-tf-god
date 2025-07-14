# modules/billing-alarm/main.tf

# Define the AWS provider specifically for this module.
# Billing metrics are only available in us-east-1, so we hardcode the region here.
# The 'profile' can be passed dynamically.
provider "aws" {
  region = var.aws_region
  profile = var.aws_profile # Use the profile passed to the module
}

# --- AWS SNS Topic for Notifications ---
resource "aws_sns_topic" "billing_alert_topic" {
  name = "${var.alarm_name_prefix}-topic"
  tags = {
    Name        = "${var.alarm_name_prefix}-topic"
    Environment = "88hours-organization"
  }
}

# --- SNS Topic Subscriptions (Email) ---
resource "aws_sns_topic_subscription" "billing_alert_email_subscriptions" {
  for_each  = toset(var.email_recipients)
  topic_arn = aws_sns_topic.billing_alert_topic.arn
  protocol  = "email"
  endpoint  = each.key
  # IMPORTANT: You will receive an email to confirm each subscription.
  # You MUST click the confirmation link in the email for alerts to work.
}

# --- CloudWatch Metric Alarm for Estimated Charges ---
resource "aws_cloudwatch_metric_alarm" "estimated_charges_alarm" {
  alarm_name          = "${var.alarm_name_prefix}-${var.billing_alert_threshold_usd}usd"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 21600 # 6 hours (in seconds)
  statistic           = "Maximum"
  threshold           = var.billing_alert_threshold_usd
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.billing_alert_topic.arn]
  ok_actions          = [aws_sns_topic.billing_alert_topic.arn] # Optional: Notify when costs go back under threshold
  treat_missing_data  = "notBreaching" # Prevents false alarms if data is temporarily unavailable

  dimensions = {
    Currency = "USD"
  }

  alarm_description = "Alarm when estimated AWS charges exceed ${var.billing_alert_threshold_usd} USD."

  tags = {
    Name        = "${var.alarm_name_prefix}-alarm"
    Environment = "production"
  }
}