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
    key    = "managment-account/backend-setup/terraform.tfstate"
    region = "ap-southeast-2"
    #dynamodb_table = "terraform-lock-table"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}
module "delegate_admin" {
  source     = "./modules/delegate-admin/iam"
  org_admin  = var.org_admin
  aws_profile = var.aws_profile
  aws_region = var.aws_region
}


# --- Call the Billing Alarm Module ---
module "billing_alarm_setup" {
  source = "./modules/org-admin/billing-alarm" # Path to your module directory

  billing_alert_threshold_usd = var.billing_alert_threshold_usd
  email_recipients            = var.email_recipients
  alarm_name_prefix           = var.alarm_name_prefix
  aws_billing_region          = var.aws_billing_region # Must be 'us-east-1'
  main_organisation_account   = var.main_organisation_account # Pass the main organization account ID
  org_admin_profile           = var.org_admin_profile # Use the profile for the organization admin}
}