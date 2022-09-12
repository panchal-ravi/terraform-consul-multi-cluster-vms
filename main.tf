locals {
  deployment_id             = lower("${var.deployment_name}-${random_string.suffix.result}")
  local_privatekey_path     = "${path.root}/private-key"
  local_privatekey_filename = var.private_key_filename
  region1                   = var.region1
  region2                   = var.region2

  region1_services = {
    web = {
      service_name  = "web",
      upstream_uris = "",
      message       = "Hello from web-region1!",
    },
    api = {
      service_name  = "api",
      upstream_uris = "",
      message       = "Hello from api-region1!",
    }
  }

  region2_services = {
    api = {
      service_name  = "api",
      upstream_uris = "",
      message       = "Hello from api-region2!"
    }
  }

  clusters = {
    "ap-southeast-1" = {
      vpc_cidr        = "10.0.0.0/16"
      private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
      public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
      instance_type   = "t3.small"
    },
    "ap-south-1" = {
      vpc_cidr        = "10.1.0.0/16"
      private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
      public_subnets  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
      instance_type   = "t3.small"
    }
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

provider "random" {}

resource "random_id" "gossip_key" {
  byte_length = 32
}


module "vpc-region1" {
  source = "./modules/infra/aws"
  providers = {
    aws = aws.region1
  }
  owner                     = var.owner
  ttl                       = var.ttl
  deployment_id             = local.deployment_id
  key_pair_key_name         = var.aws_key_pair_key_name
  vpc_cidr                  = lookup(local.clusters, local.region1).vpc_cidr
  public_subnets            = lookup(local.clusters, local.region1).public_subnets
  private_subnets           = lookup(local.clusters, local.region1).private_subnets
  local_privatekey_path     = local.local_privatekey_path
  local_privatekey_filename = local.local_privatekey_filename
}

module "vpc-region2" {
  source = "./modules/infra/aws"
  providers = {
    aws = aws.region2
  }
  owner                     = var.owner
  ttl                       = var.ttl
  deployment_id             = local.deployment_id
  key_pair_key_name         = var.aws_key_pair_key_name
  vpc_cidr                  = lookup(local.clusters, local.region2).vpc_cidr
  public_subnets            = lookup(local.clusters, local.region2).public_subnets
  private_subnets           = lookup(local.clusters, local.region2).private_subnets
  local_privatekey_path     = local.local_privatekey_path
  local_privatekey_filename = local.local_privatekey_filename
}


module "consul-server-region1" {
  source                         = "./modules/consul/aws/server"
  owner                          = var.owner
  deployment_id                  = local.deployment_id
  consul_primary_datacenter      = local.region1
  consul_datacenter              = local.region1
  consul_secondary_datacenters   = ["*.${local.region2}.consul"]
  consul_cluster_instances       = var.consul_cluster_instances
  instance_type                  = var.aws_instance_type
  key_pair_key_name              = var.aws_key_pair_key_name
  private_subnets                = module.vpc-region1.private_subnets
  public_subnets                 = module.vpc-region1.public_subnets
  vpc_id                         = module.vpc-region1.vpc_id
  vpc_cidr_block                 = module.vpc-region1.vpc_cidr_block
  consul_servers_sg_ingress_cidr = [module.vpc-region1.vpc_cidr_block, module.vpc-region2.vpc_cidr_block]
  bastion_ip                     = module.vpc-region1.bastion_ip
  gossip_key                     = random_id.gossip_key.b64_std
  retry_join_wan                 = []
  depends_on = [
    module.vpc-region1
  ]
}


module "consul-server-region2" {
  source = "./modules/consul/aws/server"
  providers = {
    aws = aws.region2
  }
  owner                          = var.owner
  deployment_id                  = local.deployment_id
  consul_primary_datacenter      = local.region1
  consul_datacenter              = local.region2
  consul_secondary_datacenters   = ["*.${local.region1}.consul"]
  consul_cluster_instances       = var.consul_cluster_instances
  instance_type                  = var.aws_instance_type
  key_pair_key_name              = var.aws_key_pair_key_name
  private_subnets                = module.vpc-region2.private_subnets
  public_subnets                 = module.vpc-region2.public_subnets
  vpc_id                         = module.vpc-region2.vpc_id
  vpc_cidr_block                 = module.vpc-region2.vpc_cidr_block
  consul_servers_sg_ingress_cidr = [module.vpc-region1.vpc_cidr_block, module.vpc-region2.vpc_cidr_block]
  bastion_ip                     = module.vpc-region2.bastion_ip
  gossip_key                     = random_id.gossip_key.b64_std
  retry_join_wan                 = module.consul-server-region1.consul_server_ips
  depends_on = [
    module.vpc-region1,
    module.vpc-region2,
    module.consul-server-region1
  ]
}

module "consul-client-ec2-region1" {
  source = "./modules/consul/aws/client/ec2"
  providers = {
    aws = aws.region1
  }
  owner                          = var.owner
  deployment_id                  = local.deployment_id
  vpc_id                         = module.vpc-region1.vpc_id
  vpc_cidr_block                 = module.vpc-region1.vpc_cidr_block
  key_pair_key_name              = var.aws_key_pair_key_name
  private_subnets                = module.vpc-region1.private_subnets
  bastion_ip                     = module.vpc-region1.bastion_ip
  instance_type                  = "t2.micro"
  gossip_key                     = random_id.gossip_key.b64_std
  consul_datacenter              = local.region1
  consul_ent_license             = file("${path.root}/files/common/consul-license")
  consul_ca_cert                 = file("${path.root}/files/common/consul-agent-ca.pem")
  consul_servers_sg_ingress_cidr = [module.vpc-region1.vpc_cidr_block, module.vpc-region2.vpc_cidr_block]

  services = local.region1_services
  depends_on = [
    module.consul-server-region1
  ]
}


module "consul-client-ec2-region2" {
  source = "./modules/consul/aws/client/ec2"
  providers = {
    aws = aws.region2
  }
  owner                          = var.owner
  deployment_id                  = local.deployment_id
  vpc_id                         = module.vpc-region2.vpc_id
  vpc_cidr_block                 = module.vpc-region2.vpc_cidr_block
  key_pair_key_name              = var.aws_key_pair_key_name
  private_subnets                = module.vpc-region2.private_subnets
  bastion_ip                     = module.vpc-region2.bastion_ip
  instance_type                  = "t2.micro"
  gossip_key                     = random_id.gossip_key.b64_std
  consul_datacenter              = local.region2
  consul_ent_license             = file("${path.root}/files/common/consul-license")
  consul_ca_cert                 = file("${path.root}/files/common/consul-agent-ca.pem")
  consul_servers_sg_ingress_cidr = [module.vpc-region1.vpc_cidr_block, module.vpc-region2.vpc_cidr_block]

  services = local.region2_services
  depends_on = [
    module.consul-server-region2
  ]
}


/*
module "consul-client-eks" {
  source               = "./modules/consul/aws/client/eks"
  region               = var.aws_region
  owner                = var.owner
  consul_datacenter    = var.consul_primary_datacenter
  deployment_id        = local.deployment_id
  key_pair_key_name    = var.aws_key_pair_key_name
  vpc_id               = module.infra-aws.vpc_id
  vpc_cidr_block       = module.infra-aws.vpc_cidr_block
  private_subnets      = module.infra-aws.private_subnets
  bastion_ip           = module.infra-aws.bastion_ip
  cluster_version      = var.aws_eks_cluster_version
  consul_version       = var.consul_version
  consul_server_ips    = module.consul-server-dc1.consul_server_ips
  worker_instance_type = var.aws_eks_worker_instance_type
  asg_desired_capacity = var.aws_eks_asg_desired_capacity
  gossip_key           = random_id.gossip_key.b64_std
  consul_ent_license   = file("${path.root}/files/consul-license")
  consul_ca_cert       = file("${path.root}/files/consul-agent-ca.pem")
  helm_chart_version   = var.consul_helm_chart_version
}
*/
