# output "server_tls_private_key" {
#   sensitive = true
#   value     = tls_private_key.this.private_key_pem
# }
# output "server_tls_public_key" {
#   value     = tls_locally_signed_cert.this.cert_pem
# }
# output "private_subnets" {
#   value = module.infra-aws.private_subnets
# }
output "deployment_id" {
  value = local.deployment_id
}

output "region1_info" {
  value = {
    bastion_ip                    = module.vpc-region1.bastion_ip,
    consul_server_ips             = module.consul-server-region1.consul_server_ips,
    consul_http_addr              = module.consul-server-region1.consul_http_addr,
    vpc_id                        = module.vpc-region1.vpc_id,
    vpc_cidr                      = module.vpc-region1.vpc_cidr_block,
    private_subnets               = module.vpc-region1.private_subnets_cidr,
    public_subnets                = module.vpc-region1.public_subnets_cidr,
    consul_client_ec2_private_ips = module.consul-client-ec2-region1.consul_client_ec2_private_ips
  }
}

output "region2_info" {
  value = {
    bastion_ip        = module.vpc-region2.bastion_ip,
    consul_server_ips = module.consul-server-region2.consul_server_ips,
    consul_http_addr  = module.consul-server-region2.consul_http_addr,
    vpc_id            = module.vpc-region2.vpc_id,
    vpc_cidr          = module.vpc-region2.vpc_cidr_block,
    private_subnets   = module.vpc-region2.private_subnets_cidr,
    public_subnets    = module.vpc-region2.public_subnets_cidr
  }
}

/*

output "region1_vpc_id" {
  value = module.vpc-region1.vpc_id
}

output "region1_vpc_cidr_block" {
  value = module.vpc-region1.vpc_cidr_block
}

output "region1_private_subnets" {
  value = module.vpc-region1.private_subnets
}

output "region1_public_subnets" {
  value = module.vpc-region1.public_subnets
}

output "region1_bastion_ip" {
  value = module.vpc-region1.bastion_ip
}

output "region2_vpc_id" {
  value = module.vpc-region2.vpc_id
}

output "region2_vpc_cidr_block" {
  value = module.vpc-region2.vpc_cidr_block
}

output "region2_private_subnets" {
  value = module.vpc-region2.private_subnets
}

output "region2_public_subnets" {
  value = module.vpc-region2.public_subnets
}

output "region2_bastion_ip" {
  value = module.vpc-region2.bastion_ip
}
*/

/*
output "consul_server_ips" {
  value = module.consul-server-dc1.consul_server_ips
}

output "consul_http_addr" {
  value = module.consul-server-dc1.consul_http_addr
}

output "ingress_gateway_public_fqdn" {
  value = module.consul-client-eks.ingress_gateway_public_fqdn
}

output "consul_client_ec2_private_ips" {
  value = module.consul-client-ec2.consul_client_ec2_private_ips
}
*/
