data "aws_ami" "an_image" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["${var.owner}-secure-consul-*"]
  }
}

resource "aws_instance" "fake-web-service" {
  for_each = var.services

  ami                    = data.aws_ami.an_image.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_key_name
  subnet_id              = var.private_subnets[index(keys(var.services), each.key) % length(keys(var.services))]
  vpc_security_group_ids = [module.allow-any-private-inbound-sg.security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name

  user_data = templatefile("${path.root}/files/client/client_template.tpl", {
    datacenter      = "${var.consul_datacenter}"
    server_name_tag = "${var.deployment_id}-server-instance",
    gossip_key      = var.gossip_key
  })

  tags = {
    Name  = "${var.deployment_id}-fake-${each.value.service_name}"
    owner = var.owner
  }
  provisioner "file" {
    source      = "${path.root}/files/client/client_acl.hcl"
    destination = "/tmp/client_acl.hcl"
  }
  provisioner "file" {
    source      = "${path.root}/files/client/fake-service"
    destination = "/tmp/fake-service"
  }
  provisioner "file" {
    source      = "${path.root}/files/common/consul-license"
    destination = "/tmp/consul-license"
  }
  provisioner "file" {
    source      = "${path.root}/files/client/fake-service.service"
    destination = "/tmp/fake-service.service"
  }
  provisioner "file" {
    content = templatefile("${path.root}/files/client/fake-service.config", {
      name          = "${each.value.service_name}"
      upstream_uris = "${each.value.upstream_uris}"
      message       = "${each.value.message}"
    })
    destination = "/tmp/fake-service.config"
  }
  provisioner "file" {
    content = templatefile("${path.root}/files/client/fake-service.hcl", {
      service_name = "${each.value.service_name}"
      tags         = "fake-service-${each.value.service_name}"
      port         = 9090
    })
    destination = "/tmp/fake-service.hcl"
  }
  provisioner "file" {
    content = templatefile("${path.root}/files/client/fake-service-envoy.service", {
      service_name = "${each.value.service_name}"
    })
    destination = "/tmp/fake-service-envoy.service"
  }
  provisioner "file" {
    content = templatefile("${path.root}/files/client/fake-service-envoy.config", {
      private_ip = "${self.private_ip}"
    })
    destination = "/tmp/fake-service-envoy.config"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt/myapp",
      "sudo mv /tmp/fake-service.service /etc/systemd/system/fake-service.service",
      "sudo mv /tmp/fake-service.config /opt/myapp/fake-service.config",
      "sudo mv /tmp/fake-service-envoy.service /etc/systemd/system/fake-service-envoy.service",
      "sudo mv /tmp/fake-service-envoy.config /opt/myapp/fake-service-envoy.config",
      "sudo mv /tmp/consul-license /etc/consul/consul.d/consul-license",
      "sudo mv /tmp/fake-service.hcl /etc/consul/consul.d/fake-service.hcl",
      "sudo mv /tmp/fake-service /opt/myapp/fake-service",
      "sudo chmod +x /opt/myapp/fake-service",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable consul.service",
      "sudo systemctl enable fake-service.service",
      "sudo systemctl enable fake-service-envoy.service",
      "sleep 30"
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "sudo systemctl start fake-service",
      "sleep 5",
      "sudo systemctl start consul",
      "sleep 10",
      "sudo systemctl start fake-service-envoy",
      "sleep 10",
      "sudo systemctl restart consul",
      "sleep 10",
      "sudo systemctl restart fake-service-envoy",
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
