variable "cidr_block" {
  type = string
 }
variable "vpc_name" {
  type = string
}

variable "env" {
  description = "The environment for the deployment (e.g., development, production)"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "subnets" {
  description = "List of subnet configurations"
  type = list(object({
     map_public_ip_on_launch = optional(bool, false) # Optional attribute for public subnets
   }))
}
 variable "create_net_gw" {
   description ="Whether to create a NAT Gateway"
   type  = bool
   default = false
   }
