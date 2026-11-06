# Add these host_volume blocks inside the existing
# client {} block of your Nomad agent configuration.

host_volume "prometheus-data" {
  path      = "/var/lib/nomad-monitoring/prometheus"
  read_only = false
}

host_volume "loki-data" {
  path      = "/var/lib/nomad-monitoring/loki"
  read_only = false
}

host_volume "grafana-data" {
  path      = "/var/lib/nomad-monitoring/grafana"
  read_only = false
}
