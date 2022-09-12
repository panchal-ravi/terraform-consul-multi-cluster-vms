resource "local_file" "consul-client-helm-values" {
  content = templatefile("${path.module}/values.yml", {
    datacenter      = "${var.consul_datacenter}"
    server_name_tag = "${var.owner}-consul-server-instance"
    server_ips      = var.consul_server_ips
    consul_version  = var.consul_version
    cloud           = "aws"
  })
  filename = "${path.module}/helm-values.yml.tmp"
}

# consul server
resource "helm_release" "consul-client" {
  name          = var.owner
  chart         = "consul"
  repository    = "https://helm.releases.hashicorp.com"
  version       = var.helm_chart_version
  namespace     = "consul"
  timeout       = "300"
  wait_for_jobs = true
  values = [
    local_file.consul-client-helm-values.content
  ]

  depends_on = [
    kubernetes_namespace.consul,
    kubernetes_secret.consul-ent-license,
    kubernetes_secret.consul-gossip-key,
    kubernetes_secret.consul-ca-cert
  ]
}
