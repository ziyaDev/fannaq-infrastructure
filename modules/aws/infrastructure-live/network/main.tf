
module "vpc" {
  source         = "../../infrastructure-modules/vpc"
  cidr_block     = "10.0.0.0/16"
  vpc_name       = "Development"
  env            = var.env
  tags           = {
    "testing"    = "true"
    }
  create_net_gw  = true
  subnets = [
      {
         map_public_ip_on_launch = true
      },
      {
         map_public_ip_on_launch = false
      },
      {
         map_public_ip_on_launch = false
      },
      {
         map_public_ip_on_launch = true
      }
    ]
  }
