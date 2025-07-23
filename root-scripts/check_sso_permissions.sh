#!/bin/bash

# Ensure required env vars exist
: "${INSTANCE_ARN:?INSTANCE_ARN not set}"
: "${ACCOUNT_ID:?ACCOUNT_ID not set}"

# List all permission sets
echo "=== Permission Sets ==="
aws sso-admin list-permission-sets \
  --instance-arn "$INSTANCE_ARN"

# Get all permission set ARNs
PERMISSION_SETS=$(aws sso-admin list-permission-sets \
  --instance-arn "$INSTANCE_ARN" \
  --query "PermissionSets[]" \
  --output text)

for PERMISSION_SET_ARN in $PERMISSION_SETS; do
  echo "=== Details for: $PERMISSION_SET_ARN ==="

  # Inline policy
  echo "--- Inline Policy ---"
  aws sso-admin get-inline-policy-for-permission-set \
    --instance-arn "$INSTANCE_ARN" \
    --permission-set-arn "$PERMISSION_SET_ARN"

  # Attached managed policies
  echo "--- Managed Policies ---"
  aws sso-admin list-managed-policies-in-permission-set \
    --instance-arn "$INSTANCE_ARN" \
    --permission-set-arn "$PERMISSION_SET_ARN"

  # Account assignments
  echo "--- Account Assignments ---"
  aws sso-admin list-account-assignments \
    --instance-arn "$INSTANCE_ARN" \
    --account-id "$ACCOUNT_ID" \
    --permission-set-arn "$PERMISSION_SET_ARN"
done
