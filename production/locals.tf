# ===============================================================================
# Local Value in Production
# ===============================================================================


# ===============================================================================
# Environment
# ===============================================================================
locals {
  env = "prd"
}


# ===============================================================================
# Network
# ===============================================================================
locals {
  vpc_cidr_block = "172.20.0.0/16"
}