output "user_ids" {
  description = "Map of user_name to created Identity Center user IDs"
  value = {
    for k, user in aws_identitystore_user.sso_users :
    k => user.user_id
  }
}

output "permission_set_arn" {
  description = "ARN of the created permission set"
  value       = aws_ssoadmin_permission_set.admin_access.arn
}
output "permission_set_name" {
  description = "Name of the created permission set"
  value       = aws_ssoadmin_permission_set.admin_access.name
}
output "assignment_principal_ids" {
  description = "Map of user_name to assigned principal IDs"
  value = {
    for k, assignment in aws_ssoadmin_account_assignment.assign_users :
    k => assignment.principal_id
  }
}
output "identity_store_id" {
  description = "Identity Store ID where SSO users are created"
  value       = data.aws_ssoadmin_instances.this.identity_store_ids[0]
}
output "target_account_id" {
  description = "Target AWS account ID for access assignment"
  value       = var.target_account_id
}