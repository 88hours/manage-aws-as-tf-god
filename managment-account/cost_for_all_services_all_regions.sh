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

# Detect OS and # Set time range (1 day before yesterday)
if date -v -1d &>/dev/null; then
  # macOS / BSD-style
  END_DATE=$(date -v -1d +%Y-%m-%d)
  START_DATE=$(date -v -2d +%Y-%m-%d)
else
  # GNU (Linux/CloudShell/Amazon Linux)
  END_DATE=$(date +%Y-%m-%d)
  START_DATE=$(date -d "$END_DATE - 7 days" +%Y-%m-%d)
fi
echo "Cost for all services in all regions from $START_DATE to $END_DATE:"
# Run Cost Explorer query
aws ce get-cost-and-usage \
  --time-period Start=$START_DATE,End=$END_DATE \
  --granularity DAILY \
  --metrics "UnblendedCost" \
  --group-by Type=DIMENSION,Key=SERVICE \
  --profile $PROFILE  \
  --region us-east-1 \
  | jq -r '
    .ResultsByTime[] |
    .TimePeriod.Start as $date |
    .Groups[] |
    [$date, .Keys[0], .Metrics.UnblendedCost.Amount] |
    @tsv
  ' | column -t
