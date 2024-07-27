variable "name" {
  type = string
  description = "Name of the ECR repo"
  }
variable "env" {
  type = string
   }

variable "scan_on_push" {
  type = bool
  default = false
  }
