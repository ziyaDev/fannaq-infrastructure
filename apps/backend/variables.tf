variable "env" {
  description = "The environment for the deployment (e.g., development, production)"
  type        = string
}
variable "domain_name" {
  type        = string
}
variable "alb_priority" {
  type        = number
}
variable "app_domain_name" {
  type        = string
}
variable "app_sub_domain" {
  type        = string
}
variable "alb_dns_name" {
  type        = string
}
variable "alb_zone_id" {
  type        = string
}
variable "public_subnets" {
  type        = list(string)
}
variable "security_group_id" {
  type        = string
}
variable "target_groups" {
  type        = any
}
