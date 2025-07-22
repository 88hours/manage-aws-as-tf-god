variable "aws_profile" {
  description = "The AWS credentials profile name"
  type        = string
}

variable "org_admin" {
  description = "The name of the organisation admin"
  type        = string
}

variable "aws_region" {
  type = string
}

variable "aws_billing_region" {
  type = string
}
variable "org_admin_policy" {
  description = "The name of the IAM policy for the Organization Admin"
  type        = string
}

variable "target_account_id" {
  description = "Target AWS account ID for access assignment"
  type        = string
}