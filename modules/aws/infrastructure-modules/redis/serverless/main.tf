locals {
  port = coalesce(var.port, 6379)
  security_group_name = try(coalesce(var.security_group_name, var.name), "")

  internal_ec_subnet_group_name = try(coalesce(var.ec_subnet_group_name, var.name), "")
  ec_subnet_group_name          = var.create_ec_subnet_group ? try(aws_elasticache_subnet_group.this[0].name, null) : local.internal_ec_subnet_group_name

 }

resource "aws_elasticache_serverless_cache" "redis" {
  engine = "redis"
  name   = var.name
  cache_usage_limits {
    data_storage {
      maximum =  var.maximum_data_storage
      unit    = var.data_storage_unit
    }
    ecpu_per_second {
      maximum = var.maximum_ecpu_per_second
    }
  }
  daily_snapshot_time      = "09:00"
  description              = var.description
  major_engine_version     = "7"
  snapshot_retention_limit = 1
  security_group_ids = compact(concat([try(aws_security_group.this[0].id, "")], var.security_group_ids))
  subnet_ids               = var.subnet_ids
  tags ={
    "Enviroment" = var.env
    }
}


################################################################################
# Security Group
################################################################################

resource "aws_security_group" "this" {
  count =  var.create_security_group ? 1 : 0

  name        = var.security_group_use_name_prefix ? null : local.security_group_name
  name_prefix = var.security_group_use_name_prefix ? "${local.security_group_name}-" : null
  vpc_id      = var.vpc_id
  description = coalesce(var.security_group_description, "Control traffic to/from Elasticache ServerlessCache ${var.name}")

  tags = merge(var.tags, var.security_group_tags, { Name = local.security_group_name })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "this" {
  for_each = { for k, v in var.security_group_rules : k => v if   var.create_security_group }

  # required
  type              = try(each.value.type, "ingress")
  from_port         = try(each.value.from_port, local.port)
  to_port           = try(each.value.to_port, local.port)
  protocol          = try(each.value.protocol, "tcp")
  security_group_id = aws_security_group.this[0].id

  # optional
  cidr_blocks              = try(each.value.cidr_blocks, null)
  description              = try(each.value.description, null)
  ipv6_cidr_blocks         = try(each.value.ipv6_cidr_blocks, null)
  prefix_list_ids          = try(each.value.prefix_list_ids, null)
  source_security_group_id = try(each.value.source_security_group_id, null)
}

################################################################################
# DB Subnet Group
################################################################################

resource "aws_elasticache_subnet_group" "this" {
  count =  var.create_ec_subnet_group ? 1 : 0

  name        = local.internal_ec_subnet_group_name
  description = "For Redis OSS ${var.name}"
  subnet_ids  = var.subnet_ids

  tags = var.tags
}
