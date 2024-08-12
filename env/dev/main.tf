
locals {
}
################################################################################
# VPC
################################################################################
module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  name               = "development_vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets   = ["10.0.11.0/24", "10.0.12.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false
  tags = {
    Terraform   = "true"
    Environment = var.env
  }
}

################################################################################
# Route53 Zones
################################################################################
module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 3.0"

  zones = {
    (var.domain_name) = {
      comment = "(${var.domain_name}) (${var.env})"
      tags = {
        env = var.env
      }
    }
  }
  tags = {
    ManagedBy = "Terraform"
  }
}
################################################################################
# Route53 Records
################################################################################
module "records" {
  source    = "terraform-aws-modules/route53/aws//modules/records"
  version   = "~> 3.0"
  zone_name = keys(module.zones.route53_zone_zone_id)[0]
  records = [
    {
      name = ""
      type = "A"
      alias = {
        name                   = module.alb.dns_name
        zone_id                = module.alb.zone_id
        evaluate_target_health = true
      }
     },
    module.nginx_server.route53_record,
    module.dashboard_app.route53_record,
    module.backend_app.route53_record,
    module.docs_app.route53_record,
    module.ecommerce_app.route53_record]
}
################################################################################
# ACM
################################################################################
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = var.domain_name
  zone_id     = module.zones.route53_zone_zone_id[var.domain_name]

  validation_method = "DNS"
  key_algorithm     = "RSA_2048"

  # No additional domain names for this certificate should cover.
  subject_alternative_names = [
    "*.${var.domain_name}",
  ]
  wait_for_validation = true
  tags = {
    Environment = "test"
  }
}
################################################################################
# Database
################################################################################
module "db" {
  source                      = "../../modules/aws/infrastructure-live/database"
  name                        = "global-db"
  vpc_id                      = module.vpc.vpc_id
  env                         = var.env
  vpc_cidr_block              = module.vpc.vpc_cidr_block
  private_subnets_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  public_subnets_cidr_blocks  = module.vpc.public_subnets_cidr_blocks
  database_subnet_group_name  = module.vpc.database_subnet_group_name
}
################################################################################
# ElasticCache redis
################################################################################
module "cache" {
  source                  = "../../modules/aws/infrastructure-modules/redis/serverless"
  env                     = var.env
  create_ec_subnet_group  = true
  name                    = "${var.env}-cache"
  description             = "Redis cache for the apps"
  security_group_ids      = []
  subnet_ids              = module.vpc.private_subnets
  maximum_data_storage    = 10
  data_storage_unit       = "GB"
  maximum_ecpu_per_second = 5000
  vpc_id                  = module.vpc.vpc_id
  ## Security group ##
  create_security_group      = true
  security_group_description = "Default security group for ${var.env}-cache"
  security_group_name        = "${var.env}-cache-sg"
  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = concat(module.vpc.public_subnets_cidr_blocks, module.vpc.private_subnets_cidr_blocks)
    }
  }
}
################################################################################
# Apps & servers
################################################################################
# Nginx Server                                                                 #
################################################################################
module "nginx_server" {
  source            = "../../apps/nginx"
  alb_priority      = 105
  env               = var.env
  domain_name       = var.domain_name
  alb_zone_id       = module.alb.zone_id
  public_subnets    = module.vpc.public_subnets
  security_group_id = module.alb.security_group_id
  target_groups     = module.alb.target_groups
  alb_dns_name      = module.alb.dns_name
  app_domain_name   = "nginx.${var.domain_name}"
  app_sub_domain    = "nginx"
}
################################################################################
# Dashboard app                                                                 #
################################################################################
module "dashboard_app" {
  source            = "../../apps/dashboard"
  alb_priority      = 103
  env               = var.env
  domain_name       = var.domain_name
  alb_zone_id       = module.alb.zone_id
  public_subnets    = module.vpc.public_subnets
  security_group_id = module.alb.security_group_id
  target_groups     = module.alb.target_groups
  alb_dns_name      = module.alb.dns_name
  app_domain_name   = "app.${var.domain_name}"
  app_sub_domain    = "app"
}
################################################################################
# Backend app                                                                  #
################################################################################
module "backend_app" {
  source            = "../../apps/backend"
  alb_priority      = 102
  env               = var.env
  domain_name       = var.domain_name
  alb_zone_id       = module.alb.zone_id
  public_subnets    = module.vpc.public_subnets
  security_group_id = module.alb.security_group_id
  target_groups     = module.alb.target_groups
  alb_dns_name      = module.alb.dns_name
  app_domain_name   = "api.${var.domain_name}"
  app_sub_domain    = "api"
}
################################################################################
# Documentation app                                                                 #
################################################################################
module "docs_app" {
  source            = "../../apps/docs"
  alb_priority      = 101
  env               = var.env
  domain_name       = var.domain_name
  alb_zone_id       = module.alb.zone_id
  public_subnets    = module.vpc.public_subnets
  security_group_id = module.alb.security_group_id
  target_groups     = module.alb.target_groups
  alb_dns_name      = module.alb.dns_name
  app_domain_name   = "docs.${var.domain_name}"
  app_sub_domain    = "docs"
}
################################################################################
# E-commerce app                                                                 #
################################################################################
module "ecommerce_app" {
  source            = "../../apps/ecommerce"
  alb_priority      = 100
  env               = var.env
  domain_name       = var.domain_name
  alb_zone_id       = module.alb.zone_id
  public_subnets    = module.vpc.public_subnets
  security_group_id = module.alb.security_group_id
  target_groups     = module.alb.target_groups
  alb_dns_name      = module.alb.dns_name
  app_domain_name   = "www.${var.domain_name}"
  app_sub_domain    = "www"
}

################################################################################
# Load balancer
################################################################################
module "alb" {
  source                           = "terraform-aws-modules/alb/aws"
  name                             = "${var.env}-alb"
  load_balancer_type               = "application"
  vpc_id                           = module.vpc.vpc_id
  subnets                          = module.vpc.public_subnets
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true
  # Security Group
  security_group_name = "alb_sg_from_all"
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }
  # Listeners
  listeners = {
    http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    https = {
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-2016-08"
      certificate_arn = module.acm.acm_certificate_arn
      # forward = {
      #   target_group_key = (module.ecommerce_app.app_name)
      # }
      redirect = {
        status_code = "HTTP_302"
        host        = "www.${var.domain_name}"
        path        = "/"
        protocol    = "HTTPS"
      }
      rules = {
        ("to_${module.nginx_server.app_name}")  = module.nginx_server.alb_rule
        ("to_${module.dashboard_app.app_name}") = module.dashboard_app.alb_rule
        ("to_${module.backend_app.app_name}")   = module.backend_app.alb_rule
        ("to_${module.docs_app.app_name}")      = module.docs_app.alb_rule
        ("to_${module.ecommerce_app.app_name}") = module.ecommerce_app.alb_rule

      }
    }
  }
  target_groups = {
    (module.nginx_server.app_name)  = module.nginx_server.alb_target_group
    (module.dashboard_app.app_name) = module.dashboard_app.alb_target_group
    (module.backend_app.app_name)   = module.backend_app.alb_target_group
    (module.docs_app.app_name)      = module.docs_app.alb_target_group
    (module.ecommerce_app.app_name) = module.ecommerce_app.alb_target_group
  }
}
################################################################################
# Cluster
################################################################################
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "cluster_${var.env}"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }

  # Capacity provider
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  services = {
    (module.nginx_server.app_name)  = module.nginx_server.ecs_service
    (module.dashboard_app.app_name) = module.dashboard_app.ecs_service
    (module.backend_app.app_name)   = module.backend_app.ecs_service
    (module.docs_app.app_name)      = module.docs_app.ecs_service
    (module.ecommerce_app.app_name) = module.ecommerce_app.ecs_service
  }

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
