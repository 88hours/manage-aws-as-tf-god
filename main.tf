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
    region = var.aws_region
    #dynamodb_table = "terraform-lock-table"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}
module "delegate-admin" {
  source     = "./modules/delegate-admin/iam"
  org_admin  = var.org_admin
  aws_profile = var.aws_profile
}


# --- Call the Billing Alarm Module ---
module "billing_alarm_setup" {
  source = "./modules/org-admin/billing-alarm" # Path to your module directory

  billing_alert_threshold_usd = var.billing_threshold
  email_recipients            = var.alert_emails
  aws_profile                 = var.aws_profile # Pass the profile to the module's provider
  alarm_name_prefix           = var.billing_alert_name # Custom prefix for this instance
  aws_region                = var.aws_billing_region # Pass the region to the module
}
