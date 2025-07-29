# File: main.tf
terraform {
  required_version = "~> 1.12.0"
  # Uncomment the following lines if you want to use a specific cloud provider
  #cloud { 
  #  organization = "88Hours" 
  #  workspaces { 
  #    name = "88HoursTerraformMigration-Prod" 
  #  } 
  #} 
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.3.0"
    }
  }
  backend "s3" {
    bucket = "my-terraform-state-bucket-88hours"
    key    = "modules/org-admin/backend-setup/terraform.tfstate"
    region = "ap-southeast-2"
    #dynamodb_table = "terraform-lock-table"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
  alias   = "org_admin"
}


module "org_admin" {
  source             = "./modules/org-admin/iam"
  org_admin          = var.org_admin
  aws_profile        = var.aws_profile
  aws_region         = var.aws_region
  aws_billing_region = var.aws_billing_region
  org_admin_policy   = var.org_admin_policy
  target_account_id  = var.organisation_id
}
# --- Call the Billing Alarm Module ---
module "billing_alarm_setup" {
  source = "./modules/org-admin/billing-alarm" # Path to your module directory

  billing_alert_threshold_usd = var.billing_alert_threshold_usd
  email_recipients            = var.email_recipients
  alarm_name_prefix           = var.alarm_name_prefix
  aws_billing_region          = var.aws_billing_region        # Must be 'us-east-1'
  main_organisation_account   = var.main_organisation_account # Pass the main organization account ID
  org_admin_profile           = var.org_admin_profile         # Use the profile for the organization admin}
}

module "sso_users" {
  source              = "./modules/org-admin/sso-users"
  dev_users           = var.dev_users
  permission_set_name = var.permission_set_name
  target_account_id   = var.organisation_id
dev_group_name     = var.dev_group_name
  depends_on = [module.org_admin]

}

# get <root_id> from aws organizations list-roots
# aws organizations enable-policy-type --root-id <root_id> --policy-type SERVICE_CONTROL_POLICY
module "scp" {
  source            = "./modules/org-admin/scp"
  target_account_id = var.organisation_id
  ou_name           = var.dev_group_name
  depends_on        = [module.org_admin]
  
}
module "cloudtrail_logs" {
  source = "./modules/org-admin/trails-logs"

  cloudtrail_log_group_name        = var.cloudtrail_log_group_name
  cloudtrail_name                  = var.cloudtrail_name
  cloudtrail_bucket_name           = var.cloudtrail_bucket_name
  cloudtrail_global_region         = var.cloudtrail_global_region
  cloudtrail_versioning_enabled    = var.cloudtrail_versioning_enabled
  cloudtrail_cloudwatchlogs_role   = var.cloudtrail_cloudwatchlogs_role
  cloudtrail_cloudwatchlogs_policy = var.cloudtrail_cloudwatchlogs_policy
  organisation_id                  = var.organisation_id
  

}