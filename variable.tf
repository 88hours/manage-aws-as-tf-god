
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
variable "dev_users" {
  description = "List of SSO users to create"
  type = list(object({
    user_name    = string
    display_name = string
    email        = string
  }))

}

variable "organisation_id" {
  description = "The ID of the AWS Organization"
  type        = string
}
variable "permission_set_name" {
  description = "Name of the permission set"
  type        = string
}

variable "cloudtrail_log_group_name" {
  description = "Name of the CloudTrail log group"
  type        = string
  default     = "/aws/cloudtrail/cloudtrail-logs"

}

variable "cloudtrail_name" {
  description = "Name of the CloudTrail"
  type        = string
}

variable "cloudtrail_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
  type        = string
}
variable "cloudtrail_global_region" {
  description = "AWS region for the CloudTrail"
  type        = string
}
variable "cloudtrail_versioning_enabled" {
  description = "Enable versioning for the CloudTrail S3 bucket"
  type        = bool
  default     = true

}
variable "cloudtrail_cloudwatchlogs_role" {
  description = "Name of the IAM role for CloudTrail to write logs to CloudWatch"
  type        = string
  default     = "CloudTrail_CloudWatchLogs_Role"
}
variable "cloudtrail_cloudwatchlogs_policy" {
  description = "Name of the IAM policy for CloudTrail to write logs to CloudWatch"
  type        = string
  default     = "CloudTrail_CloudWatchLogs_Policy"
}