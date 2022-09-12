source "amazon-ebs" "ubuntu-image" {
  ami_name = "${var.owner}-secure-consul-{{timestamp}}"
  region = "${var.aws_region}"
  instance_type = var.aws_instance_type
  tags = {
    Name = "${var.owner}-secure-consul"
  }
  source_ami_filter {
      filters = {
        virtualization-type = "hvm"
        name = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
        // name = "ubuntu/images/*ubuntu-bionic-18.04-amd64-server-*"
        root-device-type = "ebs"
      }
      owners = ["099720109477"]
      most_recent = true
  }
  communicator = "ssh"
  ssh_username = "ubuntu"
}

build {
  sources = [
    "source.amazon-ebs.ubuntu-image"
  ]
  provisioner "file" {
    source      = "../../files/consul.service"
    destination = "/tmp/consul.service"
  }
  provisioner "file" {
    source      = "../../files/consul-common.hcl"
    destination = "/tmp/consul-common.hcl"
  }
  provisioner "file" {
    source      = "../../files/consul-agent-ca.pem"
    destination = "/tmp/consul-agent-ca.pem"
  }
  provisioner "shell" {
    inline = [
      "sleep 30",
      "sudo apt-get update",
      "sudo apt install unzip -y",
      "sudo apt install default-jre -y",
      "curl -k -O \"https://releases.hashicorp.com/consul/${var.consul_version}/consul_${var.consul_version}_linux_amd64.zip\"",
      "unzip consul_${var.consul_version}_linux_amd64.zip",
      "sudo mv consul /usr/local/bin"
    ]
  }

  provisioner "shell" {
    inline = [
      "sleep 10",
      "export ENVOY_VERSION_STRING=${var.envoy_version}",
      "curl -L https://func-e.io/install.sh | sudo bash -s -- -b /usr/local/bin",
      "export FUNC_E_PLATFORM=linux/amd64",
      "func-e use $ENVOY_VERSION_STRING",
      "sudo cp ~/.func-e/versions/$ENVOY_VERSION_STRING/bin/envoy /usr/local/bin/",
    ]
  }

  provisioner "shell"{
    inline = [
      "sudo /usr/local/bin/consul -autocomplete-install",
      "sudo useradd --system --home /etc/consul/consul.d --shell /bin/false consul",
      "sudo mkdir /etc/consul /etc/consul/consul.d /etc/consul/logs /var/lib/consul/ /var/run/consul/",
      "sudo chown -R consul:consul /etc/consul /var/lib/consul/ /var/run/consul/",
      "sudo chmod -R a+r /etc/consul/logs/",
      "sudo mv /tmp/consul.service /etc/systemd/system/consul.service",
      "sudo mv /tmp/consul-common.hcl /etc/consul/consul.d/consul-common.hcl",
      "sudo mv /tmp/consul-agent-ca.pem /etc/consul/consul.d/consul-agent-ca.pem"
    ]
  }
}
