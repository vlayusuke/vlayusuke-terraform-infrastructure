# ===============================================================================
# Terraform
# ===============================================================================
terraform {
  required_version = ">= 1.10.0, < 2.0.0"

  backend "s3" {
    bucket                   = "vlayusuke-terraform-infrastructure"
    key                      = "state/production.terraform.tfstate"
    region                   = "ap-northeast-1"
    shared_credentials_files = ["~/.aws/credentials"]
    profile                  = "terraform-infrastructure"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.93.0"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}

provider "aws" {
  region = "ap-northeast-1"

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
  region = "us-east-1"
  alias  = "virginia"

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

data "terraform_remote_state" "maintenance" {
  backend = "s3"

  config = {
    bucket = "vlayusuke-terraform-infrastructure"
    region = "ap-northeast-1"
    key    = "state/maintenance.terraform.tfstate"
  }
}
