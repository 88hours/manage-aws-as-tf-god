output "org_admin" {
  value = var.org_admin
  description = "The IAM user name for the Organization Admin."
}
output "org_admin_access_key_id" {
  description = "The Access Key ID for the Organization Admin IAM user."
  value       = aws_iam_access_key.org_admin_key.id
  sensitive   = true # Mark as sensitive as it's a secret
}

output "org_admin_secret_access_key" {
  description = "The Secret Access Key for the Organization Admin IAM user."
  value       = aws_iam_access_key.org_admin_key.secret
  sensitive   = true # Mark as sensitive as it's a secret
}

output "org_admin_login_password_initial" {
  description = "The initial password for the Organization Admin IAM user login profile. This will be null after first apply if password_reset_required is true."
  value       = aws_iam_user_login_profile.org_admin_login.password # Terraform generates a random password
  sensitive   = true # Mark as sensitive
}

output "org_admin_policy" {
  # This output provides the name of the IAM policy attached to the Organization Admin user.
  value = aws_iam_user_policy.org_admin_policy.name
  description = "The name of the IAM policy attached to the Organization Admin user."
  sensitive   = true # Mark as sensitive as it contains policy details
}