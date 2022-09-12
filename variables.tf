variable "deployment_name" {
  description = "Deployment name, used to prefix resources"
  type        = string
  default     = ""
}

variable "owner" {
  description = "Resource owner identified using an email address"
  type        = string
  default     = "rp"
}

variable "ttl" {
  description = "Resource TTL (time-to-live)"
  type        = number
  default     = 48
}

# variable "aws_region" {
#   description = "AWS region"
#   type        = string
#   default     = ""
# }

variable "aws_key_pair_key_name" {
  description = "Key pair name"
  type        = string
  default     = ""
}

variable "aws_vpc_cidr" {
  description = "AWS VPC CIDR"
  type        = string
  default     = "10.200.0.0/16"
}

variable "aws_private_subnets" {
  description = "AWS private subnets"
  type        = list(any)
  default     = ["10.200.20.0/24", "10.200.21.0/24", "10.200.22.0/24"]
}

variable "aws_private_subnets_eks" {
  description = "AWS private subnets"
  type        = list(any)
  default     = ["10.200.30.0/24", "10.200.31.0/24", "10.200.32.0/24"]
}


variable "aws_public_subnets" {
  description = "AWS public subnets"
  type        = list(any)
  default     = ["10.200.10.0/24", "10.200.11.0/24", "10.200.12.0/24"]
}

variable "aws_instance_type" {
  description = "AWS instance type"
  type        = string
  default     = "t3.micro"
}

variable "aws_eks_cluster_version" {
  description = "AWS EKS cluster version"
  type        = string
  default     = "1.22"
}


variable "aws_eks_worker_instance_type" {
  description = "EC2 worker node instance type"
  type        = string
  default     = "m5.large"
}

variable "aws_eks_asg_desired_capacity" {
  description = "Desired worker capacity in the autoscaling group"
  type        = number
  default     = 2
}

variable "consul_helm_chart_version" {
  type        = string
  description = "Helm chart version"
  default     = "0.41.1"
}

variable "consul_version" {
  default = "1.12.4+ent"
}

variable "consul_cluster_instances" {
  description = "Number of consul server instances in a cluster"
  default     = 3
}

variable "consul_servers_sg_ingress_cidr" {
  type = list(any)
  default = []
}

variable "retry_join_wan" {
  type = list(any)
  default = []
}

variable "region1" {
  type = string
}

variable "region2" {
  type = string
}

variable "private_key_filename" {
  type = string
}