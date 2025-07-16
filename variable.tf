
variable "main_organisation_account" {
  description = "The main AWS account ID for the organization"
  type        = string

}
variable "aws_profile" {
  description = "The AWS credentials profile name"
  type        = string
}
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string

}
variable "aws_billing_region" {
  description = "The name of aws organisation admin"
  type        = string
}
variable "billing_alert_name" {
  description = "Custom prefix for the billing alarm name"
  type        = string
  default     = "org-billing-alert"
}
variable "org_admin" {
  description = "The name of the IAM user"
  type        = string
}

variable "email_recipients" {
  description = "A list of email addresses to send billing alerts to."
  type        = list(string)
}

variable "billing_alert_threshold_usd" {
  description = "The estimated cost threshold in USD to trigger the billing alarm."
  type        = number
}

variable "alarm_name_prefix" {
  description = "Prefix for the alarm and SNS topic names."
  type        = string
}
variable "org_admin_profile" {
  description = "The AWS profile to use for the organization admin"
  type        = string

}
variable "org_admin_policy" {
  description = "The name of the IAM policy for the Organization Admin"
  type        = string
}
variable "sso_users" {
  description = "List of SSO users to create"
  type = list(object({
    user_name    = string
    display_name = string
    email        = string
  }))
  
}