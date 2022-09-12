output "consul_server_ips" {
  value = aws_instance.consul-server[*].private_ip
}

output "consul_http_addr" {
  value = module.elb.elb_dns_name
}
