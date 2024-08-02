variable "env" {
  description = "The environment for the deployment (e.g., development, production)"
  type        = string
}
variable "vpc_id" {
   type        = string
}
variable "name" {
   type        = string
}
variable "vpc_cidr_block" {
   type        = string
}
variable "database_subnet_group_name" {
   type        = string
}


variable "private_subnets_cidr_blocks" {
  type = list(string)
  }
variable "public_subnets_cidr_blocks" {
  type = list(string)
  }
