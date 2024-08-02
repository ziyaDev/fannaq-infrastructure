################################################################################
# Registry repo
################################################################################
locals {
 app_port = 3000
 ecs_task_exec_role_policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
 app_name = "docs_app"
 protocol = "tcp"
 app_protocol = "http"
 container_name = "docs"
 image   ="ziadr265369/bun-hello-world-s:st"
 readonly_root_filesystem = false
 route53_record = {
   name = var.app_sub_domain
   type = "A"
   alias = {
     name                   = var.alb_dns_name
     zone_id                = var.alb_zone_id
     evaluate_target_health = true
   }
  }
 alb_rule = {
   conditions = [{
     host_header = {
       values = [var.app_domain_name]
     }
   }]
   actions = [
     {
       type             = "forward"
       target_group_key = (local.app_name)
     }
   ]
   priority = var.alb_priority
 }
 alb_target_group = {
   backend_protocol                  = "HTTP"
   backend_port                      = 3000
   target_type                       = "ip"
   deregistration_delay              = 5
   load_balancing_cross_zone_enabled = true
   health_check = {
     enabled             = true
     healthy_threshold   = 5
     interval            = 30
     matcher             = "200"
     path                = "/"
     port                = "traffic-port"
     protocol            = "HTTP"
     timeout             = 5
     unhealthy_threshold = 2
   }
   # There's nothing to attach here in this definition. Instead,
   # ECS will attach the IPs of the tasks to this target group
   create_attachment = false
 }
 ecs_service = {
   cpu              = 1024
   memory           = 4096
   desired_count    = 2
   assign_public_ip = true
   # Container definition(s)
   container_definitions = {
     (local.container_name) = {
       cpu       = 512
       memory    = 1024
       essential = true
       image     = local.image
       port_mappings = [
         {
           name          = "${local.container_name}-service"
           containerPort = local.app_port
           protocol      = local.protocol
           appProtocol : local.app_protocol
         }
       ]
       environment: [
            {name: "APP_NAME", value: local.app_name}
          ],
       memory_reservation       = 50
       readonly_root_filesystem = local.readonly_root_filesystem
     }
   }


   load_balancer = {
     service = {
       target_group_arn = var.target_groups[(local.app_name)].arn
       container_name   = local.container_name
       container_port   = local.app_port
     }
   }


   # IAM Roles
   #####################
   # Task role
   tasks_iam_role_name        = "${local.container_name}-task-role"
   tasks_iam_role_description = "Example tasks IAM role for ${local.container_name}"
   tasks_iam_role_policies = {
     ReadOnlyAccess = "arn:aws:iam::aws:policy/ReadOnlyAccess"
   }
   tasks_iam_role_statements = []
   # Task execution role
   task_exec_iam_role_name        = "${local.container_name}-task-execution-role"
   task_exec_iam_role_description = "Example task execution IAM role for ${local.container_name}"
   task_exec_iam_role_policies = {
     TaskExecutionRole = local.ecs_task_exec_role_policy_arn
   }
   task_exec_iam_role_statements = []
   subnet_ids                    = var.public_subnets
   security_group_rules = {
     alb_ingress = {
       type                     = "ingress"
       from_port                = 80
       to_port                  = local.app_port
       protocol                 = "tcp"
       description              = "Service port"
       source_security_group_id = var.security_group_id
     }
     egress_all = {
       type        = "egress"
       from_port   = 0
       to_port     = 0
       protocol    = "-1"
       cidr_blocks = ["0.0.0.0/0"]
     }
     # ingress_all = {
     #   type        = "ingress"
     #   from_port   = 80
     #   to_port     = 80
     #   protocol    = "tcp"
     #   cidr_blocks = ["0.0.0.0/0"]
     # }
   }
 }
  }




module "registry" {
  source = "../../modules/aws/infrastructure-live/registry"
  env    = var.env
  app = {
    repo        = "ziyaDev/fannaq-docs"
    description = "Documentations app"
    name        = "Fannaq-docs"
  }
}
