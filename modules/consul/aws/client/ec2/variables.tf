variable "deployment_id" {
  description = "Deployment id"
  type        = string
}

variable "owner" {
  description = "Resource owner identified using an email address"
  type        = string
  default     = "rp"
}

variable "key_pair_key_name" {
  description = "Key pair name"
  type        = string
}

variable "vpc_id" {
  description = "VPC Id"
  type        = string
}
variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type        = string
}
variable "private_subnets" {
  description = "VPC private subnets"
  type        = list(string)
}

variable "consul_ent_license" {
  description = "Consul enterprise license"
  type        = string
}

variable "gossip_key" {
  type = string
}

variable "consul_ca_cert" {
  type = string
}

variable "consul_datacenter" {
  type = string
}

variable "instance_type" {
  default = "t2.micro"
  type    = string
}

variable "bastion_ip" {
  type = string
}


variable "services" {
  type = map(map(string))
}

variable "consul_servers_sg_ingress_cidr" {
  type = list(any)
}