
variable "org_admin_profile" {
  description = "The AWS credentials profile name"
  type        = string
}

variable "aws_region" {
  type = string
}
variable "sso_users" {
  description = "List of SSO users to create"
  type = list(object({
    user_name    = string
    display_name    = string
    email        = string
  }))
}

variable "permission_set_name" {
  description = "Name of the permission set"
  type        = string
  default     = "AdminAccess"
}

variable "permission_set_description" {
  description = "Description for the permission set"
  type        = string
  default     = "Admin access for SSO user"
}
