variable "variable_example_name" {
  description = "Value of variables example"
  type        = string
  default     = "ExampleValueName"
  /**
  Example
  resource "aws_instance" "app_server" {
    ami           = "ami-08d70e59c07c61a3a"
    instance_type = "t2.micro"

    tags = {
  -    Name = "ExampleAppServerInstance"
  +    Name = var.variable_example_name
    }
  }
  */
}
variable "region" {
  description = "AWS region"
  type        = string
 }
variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "ExampleAppServerInstance"
}
