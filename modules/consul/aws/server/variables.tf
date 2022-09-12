variable "consul_cluster_instances" {
  description = "Number of consul server instances in a cluster"
  default     = 3
}

variable "owner" {
  description = "owner"
  type        = string
}

variable "instance_type" {
  description = "AWS Instance type"
}

variable "key_pair_key_name" {
  description = "Key pair name"
  type        = string
}

variable "private_subnets" {
  description = "private subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "public subnets"
  type        = list(string)
}

variable "deployment_id" {
  description = "Deployment id"
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type        = string
}


variable "vpc_id" {
  description = "VPC Id"
  type        = string
}

variable "bastion_ip" {
  type = string
}

variable "gossip_key" {
  type = string
}

variable "consul_datacenter" {
  type = string
}

variable "consul_primary_datacenter" {
  type = string
}

variable "consul_secondary_datacenters" {
  type = list(string)
}

variable "consul_servers_sg_ingress_cidr" {
  type = list(any)
}

variable "retry_join_wan" {
  type = list(string)
}
