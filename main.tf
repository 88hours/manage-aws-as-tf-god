provider "aws" {
  region = "us-east-1"
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