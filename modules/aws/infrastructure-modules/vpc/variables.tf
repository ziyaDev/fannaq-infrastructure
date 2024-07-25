variable "cidr_block" {
  type = string
 }
variable "vpc_name" {
  type = string
}
variable "env" {
  type = string
}
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
