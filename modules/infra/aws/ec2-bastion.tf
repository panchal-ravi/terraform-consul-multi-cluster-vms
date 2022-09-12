locals {
  key_pair_private_key = file("${var.local_privatekey_path}/${var.local_privatekey_filename}")
}

data "aws_ami" "ubuntu20" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["${var.owner}-secure-consul-*"]
  }
}

resource "aws_instance" "bastion" {
  ami             = data.aws_ami.ubuntu20.id
  instance_type   = "t2.micro"
  key_name        = var.key_pair_key_name
  subnet_id       = element(module.vpc.public_subnets, 1)
  security_groups = [module.allow-ssh-public-inbound-sg.security_group_id]

  lifecycle {
    ignore_changes = all
  }

  tags = {
    Name  = "${var.deployment_id}-bastion"
    owner = var.owner
    TTL   = var.ttl
  }

  connection {
    host        = aws_instance.bastion.public_dns
    user        = "ubuntu"
    agent       = false
    private_key = local.key_pair_private_key
  }

  provisioner "file" {
    source      = "${var.local_privatekey_path}/${var.local_privatekey_filename}"
    destination = "/home/ubuntu/${var.local_privatekey_filename}"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ubuntu/${var.local_privatekey_filename}",
    ]
  }
}
