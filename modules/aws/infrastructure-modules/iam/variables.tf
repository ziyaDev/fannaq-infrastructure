variable "role_name" {
  type = string
  }
variable "description" {
  type = string
  }
variable "assume_role_policy" {
  type = string
  }
variable "managed_policy_arns" {
  type = list(string)
  default = []

  validation {
    condition = alltrue([
      for arn in var.managed_policy_arns : can(regex("arn:aws:iam::[0-9]{12}:policy/.+", arn))
    ])
    error_message = "Each ARN must be in the format arn:aws:iam::<account-id>:policy/<policy-name>."
  }

  }
variable "env" {
  type = string
   }
