# ===============================================================================
# Terraform
# ===============================================================================
terraform {
  required_version = "1.9.4"

  backend "s3" {
    bucket = "vlayusuke-terraform-infrastructure"
    key    = "state/maintenance.terraform.tfstate"
    region = "ap-northeast-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.47.0"
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
