


output "readonly_root_filesystem" {
  value = local.readonly_root_filesystem
}
output "image" {
  value = local.image
}

output "route53_record" {
  value = local.route53_record
  }
output "ecs_service" {
  value = local.ecs_service
  }
output "alb_target_group" {
  value = local.alb_target_group
  }
output "alb_rule" {
  value = local.alb_rule
  }
output "app_port" {
  value = local.app_port
  }
output "app_protocol" {
  value = local.app_protocol
  }
output "protocol" {
  value = local.app_protocol
  }
output "app_name" {
  value = local.app_name
  }
output "container_name" {
  value = local.container_name
  }
