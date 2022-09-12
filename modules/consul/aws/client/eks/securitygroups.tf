module "allow-ssh-public-inbound-sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "${var.deployment_id}-eks-allow_ssh_public_inbound"
  description = "Allow ssh public inbound"
  vpc_id      = var.vpc_id

  ingress_rules       = ["ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}

module "allow-any-private-inbound-sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "${var.deployment_id}-eks-allow_any_private_inbound"
  description = "Allow all inbound from private CIDR"
  vpc_id      = var.vpc_id

  ingress_rules       = ["all-all"]
  ingress_cidr_blocks = [var.vpc_cidr_block]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}
