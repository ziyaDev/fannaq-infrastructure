variable "env" {
  description = "The environment for the deployment (e.g., development, production)"
  type        = string
}
variable "apps" {
  type = list(object({
    repo = string
    description = string
    name       = string
    }))
  }
