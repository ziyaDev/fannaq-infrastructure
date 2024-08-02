variable "env" {
  type = string
  }
variable "name" {
  type = string
  }
variable "description" {
  type = string
  }
variable "vpc_id" {
  type = string
  }
variable "port" {
  type = number
  default = 6379
  }
variable "security_group_description" {
  type = string
  default = "Default serverless redis security group"
  }
variable "security_group_name" {
  type = string
  default = "RedisSG"
  }
variable "security_group_rules" {
  type = any
  default =  {}
  }
variable "create_security_group" {
  type = bool
  default = false
  }
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
variable "security_group_use_name_prefix" {
  description = "Determines whether the security group name (`var.name`) is used as a prefix"
  type        = bool
  default     = true
}


variable "security_group_tags" {
  description = "Additional tags for the security group"
  type        = map(string)
  default     = {}
}
variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "List of subnet IDs used by database subnet group created"
  type = list(string)
  }
variable "maximum_data_storage" {
  type = number
  default = 10
  }
variable "data_storage_unit" {
  type = string
  default = "GB"
  }
variable "maximum_ecpu_per_second" {
  type = number
  default = 5000
  }

variable "create_ec_subnet_group" {
  description = "Determines whether to create the database subnet group or use existing"
  type        = bool
  default     = false
}

variable "ec_subnet_group_name" {
  description = "The name of the subnet group name (existing or created)"
  type        = string
  default     = ""
}
