module "guardduty_virginia" {
  source  = "./modules/guardduty"
  project = local.project

  providers = {
    aws = aws.virginia
  }
}

module "guardduty_ohio" {
  source  = "./modules/guardduty"
  project = local.project

  providers = {
    aws = aws.ohio
  }
}

module "guardduty_california" {
  source  = "./modules/guardduty"
  project = local.project

  providers = {
    aws = aws.california
  }
}

module "guardduty_oregon" {
  source  = "./modules/guardduty"
  project = local.project

  providers = {
    aws = aws.oregon
  }
}

module "guardduty_mumbai" {
  source  = "./modules/guardduty"
  project = local.project

  providers = {
    aws = aws.mumbai
  }
}

module "guardduty_tokyo" {
  source  = "./modules/guardduty"
  project = local.project

  providers = {
    aws = aws.tokyo
  }
}

module "guardduty_seoul" {
  source  = "./modules/guardduty"
  project = local.project

  providers = {
    aws = aws.seoul
  }
}

module "guardduty_osaka" {
  source  = "./modules/guardduty"
  project = local.project

  providers = {
    aws = aws.osaka
  }
}

module "guardduty_singapore" {
  source  = "./modules/guardduty"
  project = local.project

  providers = {
    aws = aws.singapore
  }
}

module "guardduty_sydney" {
  source  = "./modules/guardduty"
  project = local.project

  providers = {
    aws = aws.sydney
  }
}

module "guardduty_canada" {
  source  = "./modules/guardduty"
  project = local.project

  providers = {
    aws = aws.canada
  }
}

module "guardduty_frankfurt" {
  source  = "./modules/guardduty"
  project = local.project

  providers = {
    aws = aws.frankfurt
  }
}

module "guardduty_ileland" {
  source  = "./modules/guardduty"
  project = local.project

  providers = {
    aws = aws.ileland
  }
}

module "guardduty_london" {
  source  = "./modules/guardduty"
  project = local.project

  providers = {
    aws = aws.london
  }
}

module "guardduty_paris" {
  source  = "./modules/guardduty"
  project = local.project

  providers = {
    aws = aws.paris
  }
}

module "guardduty_stockholm" {
  source  = "./modules/guardduty"
  project = local.project

  providers = {
    aws = aws.stockholm
  }
}

module "guardduty_saopaulo" {
  source  = "./modules/guardduty"
  project = local.project

  providers = {
    aws = aws.saopaulo
  }
}
