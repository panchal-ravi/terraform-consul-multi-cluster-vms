variable "deployment_id" {
  description = "Deployment id"
  type        = string
}

variable "region" {
  description = "AWS Region"
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

variable "helm_chart_version" {
  description = "Consul helm chart version"
  type        = string
}

variable "worker_instance_type" {
  description = "EC2 worker node instance type"
  type        = string
}

variable "asg_desired_capacity" {
  description = "Desired worker capacity in the autoscaling group"
  type        = number
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

variable "cluster_version" {
  description = "EkS k8s cluster version"
  type        = string
}

variable "cluster_service_cidr" {
  description = "AWS EKS cluster service cidr"
  type        = string
  default     = "172.20.0.0/18"
}

variable "consul_version" {
  description = "Consul version"
  type        = string
}

variable "consul_server_ips" {
  type = list(string)
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
