variable "org_admin_user_name" {
  description = "The name of the Organization Admin user"
  type        = string
  
}
# --- Variables ---
variable "dev_users" {
  description = "List of SSO users to create"
  type = list(object({
    user_name    = string
    display_name = string
    email        = string
  }))
}

variable "permission_set_name" {
  description = "Name of the permission set"
  type        = string
}

variable "permission_set_description" {
  description = "Description for the permission set"
  type        = string
  default     = "Developer Admin Access"
}

variable "target_account_id" {
  description = "Target AWS account ID for access assignment"
  type        = string
}

variable "dev_group_name" {
  description = "Name of the developer group in AWS SSO"
  type        = string
}

# --- Use static SSO instance values (replace if needed) ---
variable "sso_instance_arn" {
  description = "SSO Instance ARN"
  default     = "arn:aws:sso:::instance/ssoins-8259e2882ad5f8cf"
}

variable "identity_store_id" {
  description = "Identity Store ID for SSO"
  default     = "d-9767a50a26"
}
