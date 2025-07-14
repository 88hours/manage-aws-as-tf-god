
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
  description = "The AWS region to deploy resources in"
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

variable "billing_threshold" {
  description = "The estimated cost threshold in USD for the billing alarm."
  type        = number
}

variable "alert_emails" {
  description = "A list of email addresses to send billing alerts to."
  type        = list(string)
}
