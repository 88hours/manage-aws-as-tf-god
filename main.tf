provider "aws" {
  region = "us-east-1"
}
module "org_admin" {
  source = "./managment-account"
  org_admin   = "88HoursOrgAdmin"
}