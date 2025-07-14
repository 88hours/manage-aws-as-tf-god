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

variable "aws_billing_region" {
  description = "The AWS region where billing metrics are available. Must be 'us-east-1'."
  type        = string

}

variable "org_admin_profile" {
  description = "The AWS profile to use for the organization admin"
  type        = string
}

variable "main_organisation_account" {
  description = "The main AWS account ID for the organization"
  type        = string
}