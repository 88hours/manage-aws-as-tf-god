# modules/billing-alarm/outputs.tf

output "sns_topic_arn" {
  description = "The ARN of the SNS topic for billing alerts."
  value       = aws_sns_topic.billing_alert_topic.arn
}

output "cloudwatch_alarm_name" {
  description = "The name of the CloudWatch billing alarm."
  value       = aws_cloudwatch_metric_alarm.estimated_charges_alarm.alarm_name
}