variable "env" {
  description = "The environment for the deployment (e.g., development, production)"
  type        = string
}
variable "app" {
  type = object({
    repo = string
    description = string
    name       = string
    })
  }
