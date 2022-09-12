service {
  name = "${service_name}"
  port = ${port}
  id = "${service_name}"

  connect {
    sidecar_service {}
  }

  check {
    id       = "web-check"
    name     = "TCP on port ${port}"
    tcp      = "localhost:${port}"
    interval = "10s"
    timeout  = "1s"
  }
}
