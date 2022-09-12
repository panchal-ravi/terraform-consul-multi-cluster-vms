data "aws_ami" "an_image" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["${var.owner}-secure-consul-*"]
  }
}

resource "aws_instance" "consul-server" {
  count                  = var.consul_cluster_instances
  ami                    = data.aws_ami.an_image.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_key_name
  subnet_id              = var.private_subnets[count.index]
  vpc_security_group_ids = [module.allow-any-private-inbound-sg.security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name

  user_data = templatefile("${path.root}/files/server/server_template.tpl", {
    datacenter             = "${var.consul_datacenter}"
    primary_datacenter     = "${var.consul_primary_datacenter}"
    server_name_tag        = "${var.deployment_id}-server-instance",
    server_number          = count.index,
    server_instances_count = var.consul_cluster_instances,
    gossip_key             = var.gossip_key,
    retry_join_wan         = var.retry_join_wan
  })

  tags = {
    Name     = "${var.deployment_id}-server-instance"
    Instance = "${var.deployment_id}-server-instance-${count.index}"
    owner    = var.owner
  }
  provisioner "file" {
    source      = "${path.module}/tmp/dc1-server-consul-${count.index}.pem"
    destination = "/tmp/dc1-server-consul-${count.index}.pem"
  }
  provisioner "file" {
    source      = "${path.module}/tmp/dc1-server-consul-${count.index}-key.pem"
    destination = "/tmp/dc1-server-consul-${count.index}-key.pem"
  }
  provisioner "file" {
    source      = "${path.root}/files/server/server_acl.hcl"
    destination = "/tmp/server_acl.hcl"
  }
  provisioner "file" {
    source      = "${path.root}/files/common/consul-license"
    destination = "/tmp/consul-license"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/*.pem /etc/consul/consul.d/",
      "sudo mv /tmp/consul-license /etc/consul/consul.d/consul-license",
      "sleep 30"
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "sudo systemctl start consul"
    ]
  }
  connection {
    type                = "ssh"
    user                = "ubuntu"
    host                = self.private_ip
    private_key         = file("${path.root}/private-key/rp-key.pem")
    bastion_private_key = file("${path.root}/private-key/rp-key.pem")
    bastion_host        = var.bastion_ip
  }
}

resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = var.owner
  role        = aws_iam_role.instance_role.name
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = var.owner
  assume_role_policy = data.aws_iam_policy_document.instance_role.json
  inline_policy {
    name   = "${var.deployment_id}-metadata-access"
    policy = data.aws_iam_policy_document.metadata_access.json
  }
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "metadata_access" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
    ]
    resources = ["*"]
  }
}
