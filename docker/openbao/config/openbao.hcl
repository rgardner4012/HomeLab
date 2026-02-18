ui = false

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = true
}

storage "raft" {
  path    = "/openbao/data"
  node_id = "openbao-nas-1"
}

api_addr     = "http://192.168.0.233:8200"
cluster_addr = "http://192.168.0.233:8201"

# Disable mlock for Docker (container uses --cap-add=IPC_LOCK instead)
disable_mlock = true

# Telemetry for Prometheus scraping
telemetry {
  prometheus_retention_time = "30s"
  disable_hostname         = true
}
