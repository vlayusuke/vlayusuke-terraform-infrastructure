# ===============================================================================
# Base Local Value
# ===============================================================================
locals {
  repository = "vlayusuke/vlayusuke-terraform-infrastructure"

  project = "terraform"
  author  = "Yusuke TOMIOKA"

  production_state_file  = "production.terraform.tfstate"
  staging_state_file     = "staging.terraform.tfstate"
  development_state_file = "development.terraform.tfstate"
  maintenance_state_file = "maintenance.terraform.tfstate"
  root_state_file        = "terraform.tfstate"

  region = "ap-northeast-1"

  availability_zones = [
    "ap-northeast-1a",
    "ap-northeast-1c",
  ]

  domain = "vlayusuke.net"

  database_name             = "vlayusuke"
  database_master_user_name = "vlayusuke"
}

