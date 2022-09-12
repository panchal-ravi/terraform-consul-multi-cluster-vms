variable "owner" {
  type        = string
  description = "Owner tag to which the artifacts belong"
  default     = "packt-consul"
}
variable "consul_version" {
  type = string
  description = "Three digit Consul version to work with"
  default = "1.9.0"
}
variable "aws_region" {
  type        = string
  description = "AWS Region for image"
  default     = "ap-southeast-1"
}
variable "aws_instance_type" {
  type        = string
  description = "Instance Type for Image"
  default     = "t2.small"
}
variable "envoy_version" {
  type        = string
  description = "envoy version"
  default     = "1.22.2"
}