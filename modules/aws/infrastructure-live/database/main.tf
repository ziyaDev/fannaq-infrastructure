

data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  version = "15.4"
}
module "db" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  name = var.name
  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine            = data.aws_rds_engine_version.postgresql.engine
  engine_mode       = "provisioned"
  create_db_subnet_group = false

  ## Security group ##
  create_security_group = true
  security_group_description = "Default security group for ${var.name}-db"
  security_group_name = "${var.name}-db-sg"
  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = concat(var.private_subnets_cidr_blocks, var.public_subnets_cidr_blocks)
    }
  }


  engine_version    = data.aws_rds_engine_version.postgresql.version
  storage_encrypted = true
  db_subnet_group_name = var.database_subnet_group_name

  vpc_id               = var.vpc_id
  master_username = "root"
  manage_master_user_password = true
  manage_master_user_password_rotation = true
  master_user_password_rotate_immediately = false
  master_user_password_rotation_schedule_expression = "rate(15 days)"

  monitoring_interval = 60
  apply_immediately   = true
  skip_final_snapshot = true

  serverlessv2_scaling_configuration = {
    min_capacity = 2
    max_capacity = 10
  }
  instance_class = "db.serverless"
  instances = {
    one   = {}
    two   = {}
    three = {}
  }




}
