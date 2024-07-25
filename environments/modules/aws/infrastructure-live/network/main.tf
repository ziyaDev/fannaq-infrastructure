
module "vpc" {
  source       = "../../infrastructure-modules/vpc"
  cidr_block   = "10.0.0.0/16"
  vpc_name     = "Development"
  env          = "Development"
  tags         = {
    "testing" = "yes"
    }
  }
