#!/bin/bash

PROFILE=$1

if [[ -z "$PROFILE" ]]; then
  echo "Usage: $0 <aws-profile-name>"
  exit 1
fi
if ! aws sts get-caller-identity --profile "$PROFILE" &>/dev/null; then
  echo "Profile '$PROFILE' does not exist or is not configured correctly."
  exit 1
fi
shift  # Shift arguments to access regions

REGIONS=("$@")
if [ ${#REGIONS[@]} -eq 0 ]; then
  REGIONS=("ap-southeast-2" "us-west-1")
fi

for REGION in "${REGIONS[@]}"; do
  echo "====== REGION: $REGION ======"

  echo "-- EC2 Instances --"
  aws ec2 describe-instances --region $REGION --profile $PROFILE \
    --query 'Reservations[].Instances[?State.Name==`running`].[InstanceId,Tags]' \
    --output table

  echo "-- RDS Instances --"
  aws rds describe-db-instances --region $REGION --profile $PROFILE \
    --query 'DBInstances[].[DBInstanceIdentifier,DBInstanceClass]' \
    --output table

  echo "-- Load Balancers --"
  aws elb describe-load-balancers --region $REGION --profile $PROFILE \
    --query 'LoadBalancerDescriptions[*].[LoadBalancerName]' \
    --output table

  echo "-- Lambda Functions --"
  aws lambda list-functions --region $REGION --profile $PROFILE \
    --query 'Functions[?starts_with(FunctionName, `my`) == `true`].[FunctionName,Runtime]' \
    --output table

  echo "-- API Gateway v1 --"
  aws apigateway get-rest-apis --region $REGION --profile $PROFILE \
    --query 'items[?starts_with(name, `my`) == `true`].[id,name]' \
    --output table

  echo "-- API Gateway v2 --"
  aws apigatewayv2 get-apis --region $REGION --profile $PROFILE \
    --query 'Items[?starts_with(Name, `my`) == `true`].[ApiId,Name,ProtocolType]' \
    --output table

  echo "-- KMS Keys --"
  for KEY_ID in $(aws kms list-keys --region $REGION --profile $PROFILE --query 'Keys[*].KeyId' --output text); do
    DESC=$(aws kms describe-key --region $REGION --profile $PROFILE --key-id $KEY_ID \
      --query 'KeyMetadata.Description' --output text)
    if [[ "$DESC" != "Default*" && "$DESC" != "null" ]]; then
      echo "$KEY_ID - $DESC"
    fi
  done

  echo "-- SSM Parameters --"
  aws ssm describe-parameters --region $REGION --profile $PROFILE \
    --query 'Parameters[?contains(Name, `my`) == `true`].[Name,Type]' \
    --output table

  echo
done
echo "All resources listed for profile: $PROFILE"
echo "Script completed successfully."