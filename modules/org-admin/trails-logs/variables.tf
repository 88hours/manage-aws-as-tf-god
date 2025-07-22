variable "cloudtrail_log_group_name" {
  description = "Name of the CloudTrail log group"
  type        = string
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
}

variable "cloudtrail_cloudwatchlogs_role" {
  description = "Name of the IAM role for CloudTrail to write logs to CloudWatch"
  type        = string  
}

variable "cloudtrail_cloudwatchlogs_policy" {
  description = "Name of the IAM policy for CloudTrail to write logs to CloudWatch"
  type        = string  
}
variable "organisation_id" {
  description = "The ID of the AWS Organization"
  type        = string  
  
}