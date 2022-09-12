module "allow-any-private-inbound-sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "${var.deployment_id}-consul-allow_any_private_inbound"
  description = "Allow all inbound from private CIDR"
  vpc_id      = var.vpc_id

  ingress_rules       = ["all-all"]
  ingress_cidr_blocks = var.consul_servers_sg_ingress_cidr
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "consul-webui-http-tcp"
      source_security_group_id = module.web-sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1
}


module "web-sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "${var.deployment_id}-consul-web-sg"
  description = "Allow all web traffic"
  vpc_id      = var.vpc_id

  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}
