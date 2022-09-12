data "kubernetes_service" "consul-ingress-gateway" {
  metadata {
    name      = "${var.owner}-consul-ingress-gateway"
    namespace = "consul"
  }

  depends_on = [
    helm_release.consul-client
  ]
}


resource "kubernetes_namespace" "consul" {
  metadata {
    name = "consul"
  }
}

resource "kubernetes_secret" "consul-ent-license" {
  metadata {
    name      = "consul-ent-license"
    namespace = "consul"
  }

  data = {
    key = var.consul_ent_license
  }
}

resource "kubernetes_secret" "consul-gossip-key" {
  metadata {
    name      = "consul-gossip-encryption-key"
    namespace = "consul"
  }

  data = {
    key = var.gossip_key
  }
}

resource "kubernetes_secret" "consul-ca-cert" {
  metadata {
    name      = "consul-ca-cert"
    namespace = "consul"
  }

  data = {
    key = var.consul_ca_cert
  }
}