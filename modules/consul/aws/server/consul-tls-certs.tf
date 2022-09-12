resource "random_string" "suffix" {
  length  = 8
  special = false
}


resource "tls_private_key" "this" {
  count = var.consul_cluster_instances
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "this" {
  count = var.consul_cluster_instances
  private_key_pem = tls_private_key.this[count.index].private_key_pem

  subject {
    common_name = "server.${var.consul_datacenter}.consul"
  }
  dns_names = concat(["server.${var.consul_datacenter}.consul", "localhost", "127.0.0.1"], var.consul_secondary_datacenters)
}

resource "tls_locally_signed_cert" "this" {
  count = var.consul_cluster_instances
  cert_request_pem   = tls_cert_request.this[count.index].cert_request_pem
  ca_private_key_pem = file("${path.root}/files/common/consul-agent-ca-key.pem")
  ca_cert_pem        = file("${path.root}/files/common/consul-agent-ca.pem")


  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

resource "local_file" "tls_private_key" {
  count = var.consul_cluster_instances
  content = tls_private_key.this[count.index].private_key_pem
  filename = "${path.module}/tmp/dc1-server-consul-${count.index}-key.pem"
}

resource "local_file" "tls_public_key" {
  count = var.consul_cluster_instances
  content = tls_locally_signed_cert.this[count.index].cert_pem
  filename = "${path.module}/tmp/dc1-server-consul-${count.index}.pem"
}