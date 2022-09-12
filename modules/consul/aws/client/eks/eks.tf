module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.24.0"

  cluster_name                    = var.deployment_id
  cluster_version                 = var.cluster_version
  vpc_id                          = var.vpc_id
  subnets                         = var.private_subnets
  cluster_endpoint_private_access = true
  cluster_service_ipv4_cidr       = var.cluster_service_cidr

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = var.worker_instance_type
      key_name                      = var.key_pair_key_name
      asg_desired_capacity          = var.asg_desired_capacity
      additional_security_group_ids = [module.allow-ssh-public-inbound-sg.security_group_id, module.allow-any-private-inbound-sg.security_group_id]
    }
  ]

  tags = {
    owner = var.owner
  }
}

# The Kubernetes provider is included here so the EKS module can complete successfully. Otherwise, it throws an error when creating `kubernetes_config_map.aws_auth`.
# Retrieve EKS cluster configuration
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks --region ${var.region} update-kubeconfig --name ${var.deployment_id}"
  }

  depends_on = [
    module.eks
  ]
}
