# modules/billing-alarm/variables.tf

variable "billing_alert_threshold_usd" {
  description = "The estimated cost threshold in USD to trigger the billing alarm."
  type        = number
}

variable "email_recipients" {
  description = "A list of email addresses to send billing alerts to."
  type        = list(string)
}

variable "alarm_name_prefix" {
  description = "Prefix for the alarm and SNS topic names."
  type        = string
}

variable "aws_profile" {
  description = "The AWS profile to use for authenticating with AWS. (e.g., 'default', 'my-dev-profile')"
  type        = string
}


variable "aws_region" {
    description = "The AWS region to deploy resources in. Billing metrics are only available in us-east-1."
    type        = string
}