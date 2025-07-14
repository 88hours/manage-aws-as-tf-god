
output "org_admin" {
  value = module.managment_admin.org_admin
}
output "billing_alarm_name" {
  description = "The name of the billing alarm created by the module."
  value       = module.billing_alarm_setup.cloudwatch_alarm_name
}
output "billing_sns_topic_arn" {
  description = "The ARN of the SNS topic created by the billing alarm module."
  value       = module.billing_alarm_setup.sns_topic_arn
}

output "billing_cloudwatch_alarm_name" {
  description = "The name of the CloudWatch billing alarm created by the module."
  value       = module.billing_alarm_setup.cloudwatch_alarm_name
}
