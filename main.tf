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
    key    = "management-account/backend-setup/terraform.tfstate"
    region = "ap-southeast-2"
    #dynamodb_table = "terraform-lock-table"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = "us-east-1"
}
variable "aws_profile" {
  description = "The AWS credentials profile name"
  type        = string
}
variable "org_admin" {
  description = "The name of the IAM user"
  type        = string
}

module "managment_admin" {
  source     = "./managment-account/iam"
  org_admin  = var.org_admin
  aws_profile = var.aws_profile
}


output "org_admin" {
  value = module.managment_admin.org_admin
}