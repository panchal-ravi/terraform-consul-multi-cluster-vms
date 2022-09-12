output "consul_client_ec2_private_ips" {
  value = { for k, v in aws_instance.fake-web-service : k => v.private_ip }
}
