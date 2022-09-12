#!/usr/bin/env bash
cat << EOF > /etc/consul/consul.d/consul-client.hcl
server = false
datacenter = "${datacenter}"
retry_join = ["provider=aws tag_key=Name tag_value=${server_name_tag}"]
bind_addr = "$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
advertise_addr = "$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
client_addr = "$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
# verify_incoming = true
# verify_outgoing = true
# verify_server_hostname = true
license_path = "/etc/consul/consul.d/consul-license"

tls {
  defaults {
    ca_file = "/etc/consul/consul.d/consul-agent-ca.pem"
  }
  internal_rpc {
    verify_server_hostname = true
  }
}
auto_encrypt {
  tls = true
}
ports {
  https = -1,
  grpc = 8502
}
connect {
  enabled = true
}
EOF
cat << EOF > /etc/consul/consul.d/consul-common.hcl
log_file = "/etc/consul/logs/"
log_level = "DEBUG"
encrypt = "${gossip_key}"
encrypt_verify_incoming = true
encrypt_verify_outgoing = true
EOF
sudo systemctl start consul