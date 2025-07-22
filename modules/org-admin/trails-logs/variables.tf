variable "cloudtrail_log_group_name" {
  description = "Name of the CloudTrail log group"
  type        = string
  default     = "/aws/cloudtrail/cloudtrail-logs"
  
}

variable "cloudtrail_name" {
  description = "Name of the CloudTrail"
  type        = string
  default     = "88hours-cloudtrail"
  
}

variable "cloudtrail_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
  type        = string
  default     = "global-cloudtrail-bucket-88hours"
  
}
variable "cloudtrail_global_region" {
  description = "AWS region for the CloudTrail"
  type        = string
  default     = "us-east-1"

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