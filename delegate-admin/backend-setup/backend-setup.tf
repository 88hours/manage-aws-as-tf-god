variable "aws_profile" {
  description = "The AWS credentials profile name"
  type        = string
}
provider "aws" {
  region  = "ap-southeast-2"
  profile = var.aws_profile
}

# Create S3 bucket for Terraform backend
resource "aws_s3_bucket" "tf_state" {
  bucket        = "my-terraform-state-bucket-88hours"
  force_destroy = true

  tags = {
    Name        = "TerraformState"
    Environment = "infra"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


output "backend_config" {
  value = <<EOT
terraform {
  backend "s3" {
    bucket         = "${aws_s3_bucket.tf_state.id}"
    key            = "global/s3/terraform.tfstate"
    region         = "ap-southeast-2"
    encrypt        = true
  }
}
EOT
}
