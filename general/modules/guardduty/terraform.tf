terraform {
  required_version = "1.9.8"

  backend "s3" {
    bucket                   = "vlayusuke-terraform-infrastructure"
    key                      = "root/guardduty.terraform.tfstate"
    region                   = "ap-northeast-1"
    shared_credentials_files = ["~/.aws/credentials"]
    profile                  = "terraform-infrastructure"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.88.0"
    }
  }
}
data "aws_caller_identity" "current" {}
