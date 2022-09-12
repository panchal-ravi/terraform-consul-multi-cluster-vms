module "allow-any-private-inbound-sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "${var.deployment_id}-ec2-allow_any_private_inbound"
  description = "Allow all inbound from private CIDR"
  vpc_id      = var.vpc_id

  ingress_rules       = ["all-all"]
  ingress_cidr_blocks = var.consul_servers_sg_ingress_cidr
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}
