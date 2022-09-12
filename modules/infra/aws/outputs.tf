output "private_subnets" {
  value = module.vpc.private_subnets
}

output "private_subnets_cidr" {
  value = module.vpc.private_subnets_cidr_blocks
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "public_subnets_cidr" {
  value = module.vpc.public_subnets_cidr_blocks
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}
