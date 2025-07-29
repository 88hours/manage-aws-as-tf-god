#!/bin/bash

# --- Detect Root ID ---
ROOT_ID=$(aws organizations list-roots --query "Roots[0].Id" --output text)
echo "Root ID: $ROOT_ID"

# --- Detect Developer OU ID (by name) ---
DEV_OU_NAME="SSODeveloperGroup" # Change if your OU name is different
DEV_OU_ID=$(aws organizations list-organizational-units-for-parent \
  --parent-id "$ROOT_ID" \
  --query "OrganizationalUnits[?Name=='$DEV_OU_NAME'].Id" \
  --output text)

if [ -z "$DEV_OU_ID" ]; then
  echo "ERROR: Developer OU '$DEV_OU_NAME' not found under root ($ROOT_ID)."
  exit 1
fi

echo "Developer OU ID: $DEV_OU_ID"

# --- List SCPs attached to Root ---
echo -e "\n--- SCPs attached to Root ($ROOT_ID) ---"
aws organizations list-policies-for-target \
  --target-id "$ROOT_ID" \
  --filter SERVICE_CONTROL_POLICY \
  --query "Policies[*].{Id:Id,Name:Name,Arn:Arn}" \
  --output table

# --- List SCPs attached to Developer OU ---
echo -e "\n--- SCPs attached to Developer OU ($DEV_OU_NAME - $DEV_OU_ID) ---"
aws organizations list-policies-for-target \
  --target-id "$DEV_OU_ID" \
  --filter SERVICE_CONTROL_POLICY \
  --query "Policies[*].{Id:Id,Name:Name,Arn:Arn}" \
  --output table

