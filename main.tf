terraform { 
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
}
variable "aws_profile" {
  description = "The AWS credentials profile name"
  type        = string
}
provider "aws" {
  region  = "us-east-1"
  profile = var.aws_profile
}
variable "org_admin" {
  description = "The name of the IAM user"
  type        = string
}

module "managment_admin" {
  source    = "./managment-account"
  org_admin = var.org_admin
}

output "org_admin" {
  value = module.managment_admin.org_admin
}