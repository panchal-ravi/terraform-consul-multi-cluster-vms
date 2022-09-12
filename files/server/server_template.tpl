#!/usr/bin/env bash
cat << EOF > /etc/consul/consul.d/consul-server.hcl
server = true
datacenter = "${datacenter}"
primary_datacenter = "${primary_datacenter}"
bootstrap_expect = ${server_instances_count}
retry_join = ["provider=aws tag_key=Name tag_value=${server_name_tag}"]
%{ if length(retry_join_wan) > 0 ~}
retry_join_wan=${jsonencode(retry_join_wan)}
%{ endif ~}
bind_addr = "$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
advertise_addr = "$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
client_addr = "$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
license_path = "/etc/consul/consul.d/consul-license"
ui = true

# verify_incoming = true
# verify_outgoing = true
# verify_server_hostname = true
# ca_file = "/etc/consul/consul.d/consul-agent-ca.pem"
# cert_file = "/etc/consul/consul.d/dc1-server-consul-${server_number}.pem"
# key_file = "/etc/consul/consul.d/dc1-server-consul-${server_number}-key.pem"

tls {
  defaults {
    ca_file = "/etc/consul/consul.d/consul-agent-ca.pem"
    cert_file = "/etc/consul/consul.d/dc1-server-consul-${server_number}.pem"
    key_file = "/etc/consul/consul.d/dc1-server-consul-${server_number}-key.pem"
  }
  internal_rpc {
    verify_server_hostname = true
  }
}
ports {
  http = 8500,
  https = 8501
}
auto_encrypt {
  allow_tls = true
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