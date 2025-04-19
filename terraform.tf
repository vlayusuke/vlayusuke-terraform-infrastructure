# ===============================================================================
# Terraform
# ===============================================================================
terraform {
  required_version = ">= 1.10.0, < 2.0.0"

  backend "s3" {
    bucket                   = "vlayusuke-terraform-infrastructure"
    key                      = "root/terraform.tfstate"
    region                   = "ap-northeast-1"
    shared_credentials_files = ["~/.aws/credentials"]
    profile                  = "terraform-infrastructure"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.95.0"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "terraform-infrastructure"

  default_tags {
    tags = {
      Managed     = "terraform"
      Project     = local.project
      Environment = local.env
      Repository  = local.repository
      Author      = local.author
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  alias   = "virginia"
  profile = "terraform-infrastructure"

  default_tags {
    tags = {
      Managed     = "terraform"
      Project     = local.project
      Environment = local.env
      Repository  = local.repository
      Author      = local.author
    }
  }
}
